# Codable

Codable is a selection of code snippets to allow Dictionary and Array to work better with Swift 4's Codable

- [Limitations With Swift.Codable](#limitations-with-swiftcodable)
- [Requirements](#requirements)
- [Installation](#installation)

## Limitations With Swift.Codable

Let say your `Codable` struct or class looks like this:

```swift
struct User: Codable {
    var name: String
    var email: String
    var metadata: [String: Any]
}
```

You will be hit with _"cannot automatically synthesize 'Decodable' because '[String : Any]' does not conform to 'Decodable'"_, this is because the complier cannot know what the `Any` object will be, it could be something that does not conform to `Codable`.

With Codable all you need to do is:

```swift
enum MetadataKeys: String, CodingKey {
    case timestamp
    case locale
}

struct User: Codable {
    var name: String
    var email: String
    var metadata: CodableDictionary<MetadataKeys, AnyCodable>
}
```

Compiling this and passing JSON through works

```swift
let data = """
{
  "name":"harry",
  "email":"harry@email.com",
  "metadata": {
    "timestamp": \(Date().timeIntervalSince1970)
  }
}
""".data(using: .utf8)!

let aUser = try! JSONDecoder().decode(User.self, from: data)

dump(aUser)
// ▿ __lldb_expr_18.User
// - name: "harry"
// - email: "harry@email.com"
// ▿ metadata: ["timestamp": AnyCodable(1510158557.90589)]
//   ▿ _dictionary: 1 key/value pair
//     ▿ (2 elements)
//       - key: __lldb_expr_18.MetadataKeys.timestamp
//       ▿ value: AnyCodable(1510158557.90589)
//         - value: 1510158557.90589
```

## Requirements

- iOS
- Xcode 9.0+
- Swift 4.0

## Installation

> NOTE:
> Currently we only support Swift Package Manager

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding Codable as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/harrytwright/Codable.git", from: "1.0.0")
]
```
