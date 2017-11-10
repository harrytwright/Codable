//
//  CodableDictionary.swift
//  Codable
//
//  Created by Harry Wright on 08.11.17.
//

import Foundation

protocol MutableHashCollection {
    
    associatedtype Key: Hashable
    
    associatedtype Value
    
    @discardableResult mutating func updateValue(_ value: Value, forKey key: Key) -> Value?
}

extension Dictionary: MutableHashCollection { }

public enum CodableError: Error {
    case invalidCodingKey
}

/// CodableDictionary is a replacement for Dictionay when you need to use one.
///
/// Many times using `Dictionary` inside a `Codable` struct I get complier warnings and have
/// to manually conform to `Codable` which requires more lines of code than I want to and
/// makes me cry 🤯. So replacing Dictionary with `CodableDictionary` stops all that ear ache
/// and makes my code look nicer
public struct CodableDictionary<K: Hashable, V: Codable> where K: CodingKey {

    /// The Key of the Dictionary
    public typealias Key = K

    /// The Value of the Dictionary
    public typealias Value = V

    /// The Swift dictionary instance of the Codable Dictionay
    public var dictionary: [String: V] {
        var dict: [String: V] = [:]
        for (key, value) in self._base {
            dict.updateValue(value, forKey: key.stringValue)
        }
        return dict
    }

    /// The base storage
    internal var _base: [Key: Value]

    /// Initaliser method to create an empty dictionary
    public init() {
        _base = [:]
    }

    /// Initaliser method to create a CodableDictionary from a normal
    /// `Dictionary<String, Value>`, if the entered keys are not included
    /// they will be ignored
    ///
    /// - Note: If you don't know all the Keys and wish to store them all in JSON,
    ///         please use a `UnkeyedCodableDictionary` instead
    ///
    /// - Parameter dictionary: The Swift.Dictionary you wish to use to create
    ///                         your new Codable Dictionary.
    public init(_ dictionary: Dictionary<String, V>) {
        var dict: [K: V] = [:]
        for (key, value) in dictionary {
            guard let key = K(stringValue: key) else { continue }
            dict.updateValue(value, forKey: key)
        }

        self._base = dict
    }

    /// Initaliser method to create a `CodableDictionary` with another
    /// `CodableDictionary`
    ///
    /// - Parameter codableDictionary: The `CodableDictionary` you wish to use
    public init(_ codableDictionary: CodableDictionary<K, V>) {
        self._base = codableDictionary._base
    }
}


extension CodableDictionary: ExpressibleByDictionaryLiteral, Codable {

    /// Creates an instance initialized with the given key-value pairs.
    public init(dictionaryLiteral elements: (Key, Value)...) {
        var dict = CodableDictionary<K, V>()
        for (key, value) in elements {
            dict.updateValue(value, forKey: key)
        }

        self.init(dict)
    }

    /// Creates a new instance by decoding from the given decoder.
    ///
    /// This initializer throws an error if reading from the decoder fails, or
    /// if the data read is corrupted or otherwise invalid.
    ///
    /// - Parameter decoder: The decoder to read data from.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: K.self)

        self._base = Dictionary(uniqueKeysWithValues:
            try container.allKeys.lazy.map {
                (key: $0, value: try container.decode(V.self, forKey: $0))
            }
        )
    }

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: K.self)

        for (key, value) in _base {
            try container.encode(value, forKey: key)
        }
    }

}

extension CodableDictionary {

    public subscript(position: Dictionary<K, V>.Index) -> (key: K, value: V) {
        get {
            return _base[position]
        }
    }

}

extension CodableDictionary: MutableHashCollection {

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

    /// A type representing the sequence’s elements.
    public typealias Element = Dictionary<K, V>.Element

    /// A sequence that represents a contiguous subrange of the collection’s elements.
    ///
    /// This associated type appears as a requirement in the Sequence protocol, but it
    /// is restated here with stricter constraints. In a collection, the subsequence
    /// should also conform to Collection.A sequence that represents a contiguous subrange
    /// of the collection’s elements.
    public typealias SubSequence = Dictionary<K, V>.SubSequence

    /// A type that provides the collection’s iteration interface and encapsulates
    /// its iteration state.
    ///
    /// By default, a collection conforms to the Sequence protocol by supplying
    /// IndexingIterator as its associated Iterator type.
    public typealias Iterator = Dictionary<K, V>.Iterator

    /// Returns an iterator over the elements of this sequence.
    public func makeIterator() -> DictionaryIterator<K, V> {
        return self._base.makeIterator()
    }

    /// Returns the position immediately after the given index.
    ///
    /// The successor of an index must be well defined. For an index i into a collection
    /// c, calling c.index(after: i) returns the same index every time.
    ///
    /// - Parameter i: A valid index of the collection. i must be less than endIndex.
    /// - Returns: The index value immediately after i.
    public func index(after i: Dictionary<K, V>.Index) -> Dictionary<K, V>.Index {
        return self._base.index(after: i)
    }

    /// The position of the first element in a nonempty collection.
    ///
    /// If the collection is empty, startIndex is equal to endIndex.
    public var startIndex: Dictionary<K, V>.Index {
        return _base.startIndex
    }

    /// The collection’s “past the end” position—that is, the position one greater
    /// than the last valid subscript argument.
    ///
    /// When you need a range that includes the last element of a collection, use
    /// the half-open range operator (..<) with endIndex. The ..< operator creates
    /// a range that doesn’t include the upper bound, so it’s always safe to use with
    /// endIndex. For example:
    ///
    /// ```
    /// let numbers = [10, 20, 30, 40, 50]
    /// if let index = numbers.index(of: 30) {
    ///     print(numbers[index ..< numbers.endIndex])
    /// }
    /// // Prints "[30, 40, 50]"
    /// ```
    /// If the collection is empty, endIndex is equal to startIndex.
    public var endIndex: Dictionary<K, V>.Index {
        return _base.endIndex
    }

    /// The number of elements in the collection.
    public var count: Int {
        return _base.count
    }

    /// A Boolean value indicating whether the collection is empty.
    public var isEmpty: Bool {
        return _base.isEmpty
    }

}

extension CodableDictionary : CustomStringConvertible, CustomDebugStringConvertible {

    /// A textual representation of this instance.
    ///
    /// Instead of accessing this property directly, convert an instance of any
    /// type to a string by using the `String(describing:)` initializer. For
    /// example:
    ///
    ///     struct Point: CustomStringConvertible {
    ///         let x: Int, y: Int
    ///
    ///         var description: String {
    ///             return "(\(x), \(y))"
    ///         }
    ///     }
    ///
    ///     let p = Point(x: 21, y: 30)
    ///     let s = String(describing: p)
    ///     print(s)
    ///     // Prints "(21, 30)"
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `description` property.
    public var description: String {
        return dictionary.description
    }

    /// A textual representation of this instance, suitable for debugging.
    public var debugDescription: String {
        return dictionary.debugDescription
    }

}
