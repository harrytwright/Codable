//
//  CodableDictionary.swift
//  Codable
//
//  Created by Harry Wright on 08.11.17.
//

import Foundation

public enum CodableError: Error {
    case invalidCodingKey
}

/// <#Description#>
public struct CodableDictionary<K: Hashable, V: Codable> where K: CodingKey {

    /// <#Description#>
    public typealias Key = K

    /// <#Description#>
    public typealias Value = V

    /// <#Description#>
    public var dictionary: [String: V] {
        var dict: [String: V] = [:]
        for (key, value) in self._base {
            dict.updateValue(value, forKey: key.stringValue)
        }
        return dict
    }

    private var _base: [K:V]

    /// <#Description#>
    public init() {
        _base = [:]
    }

    /// <#Description#>
    ///
    /// - Parameter dictionary: <#dictionary description#>
    public init(_ dictionary: Dictionary<String, V>) {
        var dict: [K: V] = [:]
        for (key, value) in dictionary {
            guard let key = K(stringValue: key) else { continue }
            dict.updateValue(value, forKey: key)
        }

        self._base = dict
    }

    /// <#Description#>
    ///
    /// - Parameter codableDictionary: <#codableDictionary description#>
    public init(_ codableDictionary: CodableDictionary<K, V>) {
        self._base = codableDictionary._base
    }
}

extension CodableDictionary: ExpressibleByDictionaryLiteral, Codable {

    public init(dictionaryLiteral elements: (Key, Value)...) {
        var dict = CodableDictionary<K, V>()
        for (key, value) in elements {
            dict.updateValue(value, forKey: key)
        }

        self.init(dict)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: K.self)

        self._base = Dictionary(uniqueKeysWithValues:
            try container.allKeys.lazy.map {
                (key: $0, value: try container.decode(V.self, forKey: $0))
            }
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: K.self)

        for (key, value) in _base {
            try container.encode(value, forKey: key)
        }
    }

}

extension CodableDictionary {

    /// The Index for the Collection
    public typealias Index = Dictionary<Key, Value>.Index

    /// Removes and returns the key-value pair at the specified index.
    ///
    /// Calling this method invalidates any existing indices for use with this
    /// dictionary.
    ///
    /// - Parameter index: The position of the key-value pair to remove. `index`
    ///   must be a valid index of the dictionary, and must not equal the
    ///   dictionary's end index.
    ///
    /// - Complexity: O(*n*), where *n* is the number of key-value pairs in the
    ///   dictionary.
    public mutating func remove(at index: Index) {
        self._base.remove(at: index)
    }

    /// Updates the value stored in the dictionary for the given key, or adds a
    /// new key-value pair if the key does not exist.
    ///
    /// Use this method instead of key-based subscripting when you need to know
    /// whether the new value supplants the value of an existing key. If the
    /// value of an existing key is updated, `updateValue(_:forKey:)` returns
    /// the original value.
    ///
    /// - Parameters:
    ///   - value: The new value to add to the dictionary.
    ///   - key: The key to associate with `value`. If `key` already exists in
    ///     the dictionary, `value` replaces the existing associated value. If
    ///     `key` isn't already a key of the dictionary, the `(key, value)` pair
    ///     is added.
    /// - Returns: The value that was replaced, or `nil` if a new key-value pair
    ///   was added.
    @discardableResult
    public mutating func updateValue(_ value: Value, forKey key: Key) -> Value? {
        return self._base.updateValue(value, forKey: key)
    }

    /// Updates the value stored in the dictionary for the given key, or adds a
    /// new key-value pair if the key does not exist.
    ///
    /// Use this method instead of key-based subscripting when you need to know
    /// whether the new value supplants the value of an existing key. If the
    /// value of an existing key is updated, `updateValue(_:forKey:)` returns
    /// the original value.
    ///
    /// - Parameters:
    ///   - value: The new value to add to the dictionary.
    ///   - key: The string value for the Key
    /// - Throws: Throws `.invalidCodingKey` if the Coding Key object does not contain
    ///           the key
    @discardableResult
    public mutating func updateValue(_ value: V, forKey key: String) throws -> Value? {
        guard let codingKey = K(stringValue: key) else { throw CodableError.invalidCodingKey }
        return self.updateValue(value, forKey: codingKey)
    }

}

extension CodableDictionary: Collection {

    public typealias Element = Dictionary<K, V>.Element

    public typealias SubSequence = Dictionary<K, V>.SubSequence

    public typealias Iterator = Dictionary<K, V>.Iterator

    public subscript(position: Dictionary<K, V>.Index) -> (key: K, value: V) {
        return _base[position]
    }

    public func makeIterator() -> DictionaryIterator<K, V> {
        return self._base.makeIterator()
    }

    public func index(after i: Dictionary<K, V>.Index) -> Dictionary<K, V>.Index {
        return self._base.index(after: i)
    }

    public var startIndex: Dictionary<K, V>.Index {
        return _base.startIndex
    }

    public var endIndex: Dictionary<K, V>.Index {
        return _base.endIndex
    }

    public var count: Int {
        return _base.count
    }

}

extension CodableDictionary : CustomStringConvertible, CustomDebugStringConvertible {

    public var description: String {
        return dictionary.description
    }

    public var debugDescription: String {
        return dictionary.debugDescription
    }

}
