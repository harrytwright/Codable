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
        self._base = []
    }

    /// <#Description#>
    ///
    /// - Parameter base: <#base description#>
    public init(_ base: Array<V>) {
        self._base = base
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

    public func makeIterator() -> IndexingIterator<Array<V>> {
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
