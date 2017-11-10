import XCTest
@testable import CodableCollection

enum Key: String, CodingKey {
    case name
}

struct User: Codable {
    var name: String
}

struct Users: Codable {
    var users: UnkeyedCodableDictionary<User>
}

struct Event: Codable {
    var name: String
}

struct EventList: Codable {
    var _id: String
    var list: CodableArray<Event>
}

class CodableArrayTests: BaseTestCase {

    func testThatAnyCodableExpressibleArrayEncodes() {
        let aUser = User(name: "Harry")
        let array: AnyCodable = [AnyCodable(aUser)]

        XCTAssertNoThrow(try encoder.encode(array))
    }

    func testThatAnyCodableExpressibleArrayProducesValidJSON() {
        run {
            let json: String = """
            [
              {
                "name" : "Harry"
              }
            ]
            """

            let aUser = User(name: "Harry")
            let array: AnyCodable = [AnyCodable(aUser)]

            let encodedData = try encoder.encode(array)
            guard let string = String(data: encodedData, encoding: .utf8) else {
                XCTFail(); return
            }

            XCTAssertEqual(string, json)


        }
    }

    func test() {
        run {
            let aUser = User(name: "Harry")
            let users = Users(users: ["qwertyuiop":aUser])

            let encodedData = try encoder.encode(users)
            let string = String(data: encodedData, encoding: .utf8)!
            print(string)

        }
    }

    func testNew() {
        run {
            let anEvent = Event(name: "addedItemToBasket")
            let events = EventList(_id: "addedItemToBasket", list: [])

            addChanges(anEvent, in: events, forKeyPath: \EventList.list)
        }
    }

    static var allTests = [
        ("testAnyCodableArrayEncodes", testThatAnyCodableExpressibleArrayEncodes),
        ("testAnyCodableProducesValidJSON", testThatAnyCodableExpressibleArrayProducesValidJSON)
    ]
}

