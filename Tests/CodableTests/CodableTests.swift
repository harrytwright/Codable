import XCTest
@testable import Codable

enum Key: String, CodingKey {
    case name
}

struct User: Codable {
    var name: AnyCodable
}

class CodableTests: XCTestCase {

    func testExample() {
        let aUser = User(name: "Harry")
        let array: CodableArray<User> = [aUser]

        XCTAssertNoThrow(try JSONEncoder().encode(array))
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
