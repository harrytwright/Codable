import Foundation

protocol Nestable: Codable { }

internal protocol _AnyCodableBox {

    var _base: Any { get }

    var objectIdentifier: ObjectIdentifier { get }

}

internal struct _ConcreteCodableBox<Base : Codable> : _AnyCodableBox {

    internal var _baseCodable: Base

    var objectIdentifier: ObjectIdentifier {
        return ObjectIdentifier(type(of: _baseCodable))
    }

    init(_ base: Base) {
        self._baseCodable = base
    }

    var _base: Any {
        return _baseCodable
    }
}

public struct AnyCodable: Encodable, Decodable {

    internal var _box: _AnyCodableBox

    public var base: Any {
        return _box._base
    }

    public var objectIdentifier: ObjectIdentifier {
        return _box.objectIdentifier
    }

    public init<Base: Codable>(_ base: Base) {
        self._box = _ConcreteCodableBox<Base>(base)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self._box = _ConcreteCodableBox<Int>(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self._box = _ConcreteCodableBox<Double>(doubleValue)
        } else if let floatValue = try? container.decode(Float.self) {
            self._box = _ConcreteCodableBox<Float>(floatValue)
        } else if let stringValue = try? container.decode(String.self) {
            self._box = _ConcreteCodableBox<String>(stringValue)
        } else if let dictionaryValue = try? container.decode([String:AnyCodable].self) {
            self._box = _ConcreteCodableBox<[String:AnyCodable]>(dictionaryValue)
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            self._box = _ConcreteCodableBox<[AnyCodable]>(arrayValue)
        } else {
            throw DecodingError.typeMismatch(
                type(of: self),
                .init(codingPath: decoder.codingPath, debugDescription: "Unsupported JSON type")
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        // Safe to use `as!` becasue the `_base` is just `_baseCodable`
        try (self._box._base as! Codable).encode(to: encoder)
    }

}

/**
 Having AnyCodable conforming to the Expressible methods means users can
 create a dictionary or array that looks like a normal one
 */
extension AnyCodable:
    ExpressibleByStringLiteral,
    ExpressibleByIntegerLiteral,
    ExpressibleByBooleanLiteral,
    ExpressibleByFloatLiteral,
    ExpressibleByArrayLiteral
{

    public init(arrayLiteral elements: AnyCodable...) {
        self.init(CodableArray<AnyCodable>(elements))
    }

    public init(stringLiteral value: String) {
        self.init(value)
    }

    public init(integerLiteral value: Int) {
        self.init(value)
    }

    public init(booleanLiteral value: Bool) {
        self.init(value)
    }

    public init(floatLiteral value: Float) {
        self.init(value)
    }

}

extension AnyCodable: Hashable {

    public static func ==(lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public var hashValue: Int {
        if let hash = try? JSONEncoder().encode(self).hashValue {
            return hash
        } else if self.base is Int {
            return (self.base as! Int).hashValue
        } else if self.base is Double {
            return (self.base as! Double).hashValue
        } else if self.base is Float {
            return (self.base as! Float).hashValue
        } else if self.base is Bool {
            return (self.base as! Bool).hashValue
        } else if self.base is String {
            return (self.base as! String).hashValue
        }

        return 1 ^ 5
    }


}


extension AnyCodable: CustomStringConvertible {

    public var description: String {
        return "AnyCodable(\(self.base))"
    }
}

extension AnyCodable: CustomReflectable {

    public var customMirror: Mirror {
        return Mirror(
            self,
            children: [
                "value": base
            ]
        )
    }
    
}
