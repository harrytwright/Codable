# CodableCollection

Codable is a selection of type-safe Collections to keep you safe.

- [Limitations With Swift.Codable](#limitations-with-swiftcodable)
- [Requirements](#requirements)
- [Installation](#installation)

## Limitations With Swift.Codable

Let say you're an Analytics SDK platform, and you have a `userInfo` parameter where you don't know the keys and objects to be entered as a end developer enters them, so your `Struct` will look like this:

```swift
struct Event: Codable {
    var name: String
    var userInfo: [String: Any]
}
```

However, you will be hit with _"cannot automatically synthesize 'Decodable' because '[String : Any]' does not conform to 'Decodable'"_, this is because the complier cannot know what the `Any` object will be, it could be something that does not conform to `Codable`.

With CodableCollection all you need to do is:

```swift

struct Event: Codable {
    var name: String
    var userInfo: UnkeyedCodableDictionary<AnyCodable>
}
```

Mocking up with an event will produce:

```swift
AnalyticsSDK.logEvent("SignUp", userInfo: ["user":"qwertyuiop", "email":"abc@xyz.com"])

// ▿ __lldb_expr_7.Event
//   - name: "SignUp"
//   ▿ userInfo: ["user": AnyCodable(qwertyuiop), "email": AnyCodable(abc@xyz.com)]
//     ▿ _base: ["user": AnyCodable(qwertyuiop), "email": AnyCodable(abc@xyz.com)]
//       ▿ _base: 2 key/value pairs
//         ▿ (2 elements)
//           ▿ key: user
//             - stringValue: "user"
//             - intValue: nil
//           ▿ value: AnyCodable(qwertyuiop)
//             - value: "qwertyuiop"
//         ▿ (2 elements)
//           ▿ key: email
//             - stringValue: "email"
//             - intValue: nil
//           ▿ value: AnyCodable(abc@xyz.com)
//             - value: "abc@xyz.com"
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
    .package(url: "https://github.com/harrytwright/CodableCollection.git", from: "0.3.0")
]
```
