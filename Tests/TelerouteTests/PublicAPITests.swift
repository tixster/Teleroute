import Testing
import Teleroute

@Test func externalCodeCanCreateFlowSessionForCustomStorage() {
    let session = TelerouteFlowSession(
        id: "SignupFlow",
        step: "name",
        values: .init(["name": "Alice"])
    )

    #expect(session.id == "SignupFlow")
    #expect(session.step == "name")
    #expect(session.values["name"] == "Alice")
}
