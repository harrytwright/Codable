//
//  AnyCodable.swift
//  Codable
//
//  Created by Harry Wright on 08.11.17.
//

import Foundation

internal protocol _AnyCodableBox {

    var _base: Any { get }

}

internal struct _ConcreteCodableBox<Base : Codable> : _AnyCodableBox {

    internal var _baseCodable: Base

    init(_ base: Base) {
        self._baseCodable = base
    }

    var _base: Any {
        return _baseCodable
    }
}

/// <#Description#>
public struct AnyCodable: Encodable, Decodable {

    internal var _box: _AnyCodableBox

    /// <#Description#>
    public var base: Any {
        return _box._base
    }

    /// <#Description#>
    ///
    /// - Parameter base: <#base description#>
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
        } else if let boolValue = try? container.decode(Bool.self) {
            self._box = _ConcreteCodableBox<Bool>(boolValue)
        } else {
            throw DecodingError.typeMismatch(
                type(of: self),
                .init(codingPath:
                    decoder.codingPath,
                      debugDescription: "Unsupported JSON type"
                )
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
