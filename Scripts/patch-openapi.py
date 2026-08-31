#!/usr/bin/env python3
"""Patch the Telegram Bot API OpenAPI spec for swift-openapi-generator.

Transformations (all deterministic and idempotent):
  1. Inline single-$ref allOf wrappers so nested access does not become `.value1`.
  2. Hoist the repeated inline `oneOf [int64, string]` into a shared ChatId schema.
  3. Hoist the repeated 4-variant reply_markup oneOf into a shared ReplyMarkup schema.
  4. Rewrite InputFile from an empty object to a binary string.

Usage: patch-openapi.py <input.json> <output.json>
"""

import json
import sys

CHAT_ID_REF = "#/components/schemas/ChatId"
REPLY_MARKUP_REF = "#/components/schemas/ReplyMarkup"

CHAT_ID_ONE_OF = [
    {"type": "integer", "format": "int64"},
    {"type": "string"},
]

REPLY_MARKUP_ONE_OF = [
    {"$ref": "#/components/schemas/InlineKeyboardMarkup"},
    {"$ref": "#/components/schemas/ReplyKeyboardMarkup"},
    {"$ref": "#/components/schemas/ReplyKeyboardRemove"},
    {"$ref": "#/components/schemas/ForceReply"},
]

counts = {
    "allof_inlined": 0,
    "chat_id_hoisted": 0,
    "reply_markup_hoisted": 0,
    "input_file_rewritten": 0,
    "union_hoisted": 0,
    "get_converted": 0,
}

# frozenset of member $refs -> component name, for pure oneOf-of-refs
# component schemas (e.g. InputMedia). Filled in main() before transform.
union_components = {}

# Inline unions that match no existing component get hoisted under these
# synthesized names so the generated Swift API stays readable.
SYNTHESIZED_UNIONS = {
    frozenset(
        f"#/components/schemas/{name}"
        for name in (
            "InputMediaAudio",
            "InputMediaDocument",
            "InputMediaLivePhoto",
            "InputMediaPhoto",
            "InputMediaVideo",
        )
    ): "MediaGroupInputMedia",
}


def is_single_ref_allof(node):
    """{"allOf": [{"$ref": X}], ...only-description siblings}"""
    if not isinstance(node, dict) or "allOf" not in node:
        return False
    all_of = node["allOf"]
    if not (isinstance(all_of, list) and len(all_of) == 1):
        return False
    inner = all_of[0]
    if not (isinstance(inner, dict) and set(inner.keys()) == {"$ref"}):
        return False
    # Only inline when the siblings carry no schema semantics.
    return set(node.keys()) <= {"allOf", "description"}


def is_chat_id_oneof(node):
    return (
        isinstance(node, dict)
        and node.get("oneOf") == CHAT_ID_ONE_OF
        and set(node.keys()) <= {"oneOf", "description"}
    )


def is_reply_markup_oneof(node):
    return (
        isinstance(node, dict)
        and node.get("oneOf") == REPLY_MARKUP_ONE_OF
        and set(node.keys()) <= {"oneOf", "description"}
    )


def matching_union_component(node):
    """The component name whose oneOf-of-refs exactly matches this inline node."""
    if not (isinstance(node, dict) and set(node.keys()) <= {"oneOf", "description"}):
        return None
    one_of = node.get("oneOf")
    if not (isinstance(one_of, list) and all(
        isinstance(e, dict) and set(e.keys()) == {"$ref"} for e in one_of
    )):
        return None
    refs = frozenset(e["$ref"] for e in one_of)
    return union_components.get(refs) or SYNTHESIZED_UNIONS.get(refs)


def transform(node, path):
    if isinstance(node, list):
        return [transform(item, path + (i,)) for i, item in enumerate(node)]
    if not isinstance(node, dict):
        return node

    # Never rewrite the shared component definitions themselves.
    is_component_def = len(path) == 3 and path[0] == "components" and path[1] == "schemas"

    if not is_component_def:
        if is_single_ref_allof(node):
            counts["allof_inlined"] += 1
            return {"$ref": node["allOf"][0]["$ref"]}
        if is_chat_id_oneof(node):
            counts["chat_id_hoisted"] += 1
            return {"$ref": CHAT_ID_REF}
        if is_reply_markup_oneof(node):
            counts["reply_markup_hoisted"] += 1
            return {"$ref": REPLY_MARKUP_REF}
        union = matching_union_component(node)
        if union is not None:
            counts["union_hoisted"] += 1
            return {"$ref": f"#/components/schemas/{union}"}

    return {key: transform(value, path + (key,)) for key, value in node.items()}


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    input_path, output_path = sys.argv[1], sys.argv[2]

    with open(input_path) as handle:
        spec = json.load(handle)

    already_patched = "ChatId" in spec.get("components", {}).get("schemas", {})

    # Telegram parses query strings loosely: array- and object-valued
    # parameters must be JSON-serialized, which OpenAPI query serialization
    # does not produce (it explodes arrays into repeated keys, and Telegram
    # silently ignores them — e.g. `allowed_updates` on getUpdates). Telegram
    # accepts POST with a JSON body for every method, so convert each GET
    # operation into an equivalent POST + application/json requestBody.
    for path_item in spec["paths"].values():
        operation = path_item.pop("get", None)
        if operation is None:
            continue
        properties = {}
        required = []
        for parameter in operation.pop("parameters", []):
            properties[parameter["name"]] = dict(
                parameter["schema"],
                **({"description": parameter["description"]} if "description" in parameter else {}),
            )
            if parameter.get("required"):
                required.append(parameter["name"])
        if properties:
            schema = {"type": "object", "properties": properties}
            if required:
                schema["required"] = required
            operation["requestBody"] = {
                "required": True,
                "content": {"application/json": {"schema": schema}},
            }
        path_item["post"] = operation
        counts["get_converted"] += 1

    for name, schema in spec["components"]["schemas"].items():
        if name in ("ChatId", "ReplyMarkup"):
            continue
        one_of = schema.get("oneOf")
        if isinstance(one_of, list) and one_of and all(
            isinstance(e, dict) and set(e.keys()) == {"$ref"} for e in one_of
        ):
            union_components[frozenset(e["$ref"] for e in one_of)] = name

    spec = transform(spec, ())

    schemas = spec["components"]["schemas"]
    for refs, name in SYNTHESIZED_UNIONS.items():
        schemas.setdefault(
            name,
            {"oneOf": [{"$ref": ref} for ref in sorted(refs)]},
        )
    schemas.setdefault(
        "ChatId",
        {
            "oneOf": CHAT_ID_ONE_OF,
            "description": (
                "Unique identifier for the target chat or username of the "
                "target channel (in the format `@channelusername`)"
            ),
        },
    )
    schemas.setdefault(
        "ReplyMarkup",
        {
            "oneOf": REPLY_MARKUP_ONE_OF,
            "description": "Additional interface options for the sent message.",
        },
    )

    input_file = schemas.get("InputFile")
    if input_file is not None and input_file.get("type") != "string":
        schemas["InputFile"] = {
            "type": "string",
            "format": "binary",
            "description": input_file.get(
                "description", "The contents of a file to be uploaded."
            ),
        }
        counts["input_file_rewritten"] += 1

    # Guard against silent spec-shape drift: a fresh (unpatched) input must
    # actually contain every pattern this script exists to fix.
    if not already_patched:
        for key, minimum in (
            ("allof_inlined", 100),
            ("chat_id_hoisted", 50),
            ("reply_markup_hoisted", 10),
            ("input_file_rewritten", 1),
            ("get_converted", 25),
        ):
            if counts[key] < minimum:
                sys.exit(
                    f"patch-openapi: expected at least {minimum} "
                    f"{key} rewrites, got {counts[key]} — spec shape changed?"
                )

    with open(output_path, "w") as handle:
        json.dump(spec, handle, indent=2, ensure_ascii=False)
        handle.write("\n")

    print(
        "patch-openapi:",
        ", ".join(f"{key}={value}" for key, value in sorted(counts.items())),
    )


if __name__ == "__main__":
    main()
