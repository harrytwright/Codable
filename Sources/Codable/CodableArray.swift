//
//  CodableArray.swift
//  Codable
//
//  Created by Harry Wright on 08.11.17.
//

import Foundation

extension Array where Element : Codable {
    func toCodable() -> CodableArray<Element> {
        return CodableArray(self)
    }
}

public struct CodableArray<V: Codable> {

    public var array: Array<V> {
        return _base
    }

    private var _base: Array<V>

    /// <#Description#>
    public init() {
        self = []
    }

    /// <#Description#>
    ///
    /// - Parameter base: <#base description#>
    public init(_ base: Array<V>) {
        self = base.toCodable()
    }

    /// <#Description#>
    ///
    /// - Parameter sequence: <#base description#>
    public init<S: Sequence>(_ sequence: S) where S.Element == V {
        self = Array<V>(sequence).toCodable()
    }

    /// <#Description#>
    ///
    /// - Warning:  We filter the array to remove all non Codable elements
    ///             but somtimes the this doesn't work for certain Objects.
    /// - Parameter cocoa: An NSArray of objects
    public init(_ cocoa: NSArray) {
        // Can use `as!` because the prior filter will make sure all
        // remaining Elements conform to Codable
        self._base = (cocoa as! Array<Any>).filter { $0 is Codable } as! Array<V>
    }

    /// <#Description#>
    ///
    /// - Parameter codableArray: <#codableArray description#>
    public init(_ codableArray: CodableArray<V>) {
        self = codableArray
    }

}

extension CodableArray: ExpressibleByArrayLiteral, Encodable, Decodable {

    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }

    public init(from decoder: Decoder) throws {
        var array: [V] = []

        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            array.append(try container.decode(V.self))
        }
        
        self._base = array
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: _base)
    }
    
}

extension CodableArray: Collection {

    public typealias Index = Array<V>.Index

    public typealias Element = Array<V>.Element

    public typealias SubSequence = Array<V>.SubSequence

    public typealias Iterator = Array<V>.Iterator

    public subscript(position: CodableArray.Index) -> V {
        return self._base[position]
    }

    public func makeIterator() -> Iterator {
        return self._base.makeIterator()
    }

    public func index(after i: CodableArray<V>.Index) -> CodableArray<V>.Index {
        return self._base.index(after: i)
    }

    public var startIndex: CodableArray.Index {
        return self._base.startIndex
    }

    public var endIndex: CodableArray.Index {
        return self._base.endIndex
    }

}
