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

public struct CodableArray<Element: Codable> {

    public var array: Array<Element> {
        return _base
    }

    private var _base: Array<Element>

    /// <#Description#>
    public init() {
        self = []
    }

    /// <#Description#>
    ///
    /// - Parameter base: <#base description#>
    public init(_ base: Array<Element>) {
        self._base = base
    }

    /// <#Description#>
    ///
    /// - Parameter sequence: <#base description#>
    public init<S: Sequence>(_ sequence: S) where S.Element == Element {
        self._base = Array<Element>(sequence)
    }

    /// <#Description#>
    ///
    /// - Warning:  We filter the array to remove all non Codable elements
    ///             but somtimes the this doesn't work for certain Objects.
    /// - Parameter cocoa: An NSArray of objects
    public init(_ cocoa: NSArray) {
        // Can use `as!` because the prior filter will make sure all
        // remaining Elements conform to Codable
        self._base = (cocoa as! Array<Any>).filter { $0 is Codable } as! Array<Element>
    }

    /// <#Description#>
    ///
    /// - Parameter codableArray: <#codableArray description#>
    public init(_ codableArray: CodableArray<Element>) {
        self = codableArray
    }

}

extension CodableArray: ExpressibleByArrayLiteral, Encodable, Decodable {

    public init(arrayLiteral elements: Element...) {
        self.init(elements)
    }

    public init(from decoder: Decoder) throws {
        var array: [Element] = []

        var container = try decoder.unkeyedContainer()
        while !container.isAtEnd {
            array.append(try container.decode(Element.self))
        }
        
        self._base = array
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: _base)
    }
    
}

extension CodableArray: RangeReplaceableCollection {

    public mutating func append(_ newElement: Element) {
        self._base.append(newElement)
    }

    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, Element == S.Element {
        self.append(contentsOf: newElements)
    }

}

extension CodableArray: Collection {

    public typealias Index = Array<Element>.Index

    public typealias SubSequence = Array<Element>.SubSequence

    public typealias Iterator = Array<Element>.Iterator

    public subscript(position: CodableArray.Index) -> Element {
        return self._base[position]
    }

    public func makeIterator() -> Iterator {
        return self._base.makeIterator()
    }

    public func index(after i: CodableArray<Element>.Index) -> CodableArray<Element>.Index {
        return self._base.index(after: i)
    }

    public var startIndex: CodableArray.Index {
        return self._base.startIndex
    }

    public var endIndex: CodableArray.Index {
        return self._base.endIndex
    }

    public mutating func insert(_ newElement: Element, at i: CodableArray.Index) {
        self._base.insert(newElement, at: i)
    }

    public func enumerated() -> EnumeratedSequence<Array<Element>> {
        return self._base.enumerated()
    }

    @discardableResult
    public mutating func remove(at position: Array<Element>.Index) -> Element {
        return self._base.remove(at: position)
    }

    public func filter(_ isIncluded: @escaping (Element) throws -> Bool) rethrows -> [Element] {
        return try self.filter(isIncluded)
    }

}
