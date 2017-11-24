public struct UnkeyedKeys: CodingKey, Hashable {

    public var stringValue: String

    public init?(stringValue: String) {
        self.stringValue = stringValue
    }

    public var intValue: Int?

    public init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }

    public var hashValue: Int {
        return stringValue.hashValue
    }

    public static func ==(lhs: UnkeyedKeys, rhs: UnkeyedKeys) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

}

/// `UnkeyedCodableDictionary` is a Dictionary like struct that work for times you don't know
/// all the Keys.
///
/// An example would be if your Analytics SDK has a method like this:
///
/// ```swift
/// func logCustomEvent(_:userInfo:)
/// ```
///
/// As it is a custom event and the user can add there own UserInfo you can't gage all keys and
/// they could be needed by the user. So using `UnkeyedCodableDictionary` all you need to do is
/// add `UnkeyedCodableDictionary<AnyCodable>` in place of any Dictionaries or structs, like so:
///
/// ```
/// struct Event: Codable {
///     var name: String
///     var userInfo: UnkeyedCodableDictionary<AnyCodable>
/// }
///
/// let data = """
/// {
///     "name": "custom",
///     "userInfo" : {
///         "name" : "Harry",
///         "device": "iPhone X 11.1.1"
///     }
/// }
/// """.data(using: .utf8)!
///
/// do {
///     let anEvent = try JSONDecoder().decode(Event.self, from: data)
///     dump(anEvent) // Shows the working of anEvent
/// } catch {
///     print(error) // Never gets called
/// }
/// ```
public struct UnkeyedCodableDictionary<Value: Codable>: Decodable, Encodable {

    public typealias Key = String

    /// <#Description#>
    public var dictionary: [String: Value] {
        return _base.dictionary
    }

    internal var _base: CodableDictionary<UnkeyedKeys, Value> = [:]

    /// <#Description#>
    ///
    /// - Parameter base: <#base description#>
    public init(_ base: [String: Value]) {
        self._base = CodableDictionary(base)
    }

    /// <#Description#>
    ///
    /// - Parameter unkeyedCodableDictionary: <#unkeyedCodableDictionary description#>
    public init(_ unkeyedCodableDictionary: UnkeyedCodableDictionary<Value>) {
        self = unkeyedCodableDictionary
    }

    public init(from decoder: Decoder) throws {
        var dictionary: [String: Value] = [:]

        let container = try decoder.container(keyedBy: UnkeyedKeys.self)
        for key in container.allKeys {
            if let value = try? container.decode(Value.self, forKey: key) {
                dictionary[key.stringValue] = value
            }
        }
        self.init(dictionary)
    }

    public func encode(to encoder: Encoder) throws {
        try _base.encode(to: encoder)
    }

}

extension UnkeyedCodableDictionary: ExpressibleByDictionaryLiteral {

    public init(dictionaryLiteral elements: (Key, Value)...) {
        var dict = Dictionary<String, Value>()
        for (key, value) in elements {
            dict.updateValue(value, forKey: key)
        }

        self.init(dict)
    }

}

extension UnkeyedCodableDictionary: MutableHashCollection {

    public subscript(position: Dictionary<UnkeyedCodableDictionary.Key, Value>.Index) -> (key: UnkeyedCodableDictionary.Key, value: Value) {
        get {
            return self.dictionary[position]
        }
    }

    public subscript(key: Key) -> Value? {
        return self.dictionary[key]
    }
    
    public mutating func updateValue(_ value: Value, forKey key: String) -> Value? {
        guard let key = UnkeyedKeys(stringValue: key) else { return nil }
        return self._base.updateValue(value, forKey: key)
    }
}

extension UnkeyedCodableDictionary: Collection {

    public typealias Element = Dictionary<Key, Value>.Element

    public typealias SubSequence = Dictionary<Key, Value>.SubSequence

    public typealias Iterator = Dictionary<Key, Value>.Iterator

    public func makeIterator() -> DictionaryIterator<Key, Value> {
        return self.dictionary.makeIterator()
    }

    public func index(after i: Dictionary<Key, Value>.Index) -> Dictionary<Key, Value>.Index {
        return self.dictionary.index(after: i)
    }

    public var startIndex:  Dictionary<Key, Value>.Index {
        return self.dictionary.startIndex
    }

    public var endIndex:  Dictionary<Key, Value>.Index {
        return self.dictionary.endIndex
    }

    public var count: Int {
        return self.dictionary.count
    }
}

extension UnkeyedCodableDictionary : CustomStringConvertible, CustomDebugStringConvertible {

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
