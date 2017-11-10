//
//  BaseTestCase.swift
//  CodableTests
//
//  Created by Harry Wright on 08.11.17.
//

import XCTest
import CodableCollection

func addChanges<Change: Codable, Object: Codable, S: RangeReplaceableCollection>(
    _ changes: Change,
    in object: Object,
    forKeyPath keyPath: WritableKeyPath<Object, S>,
    callback: (() -> Void)? = nil
    ) where S.Element == Change
{
    var newObject = object
    newObject[keyPath: keyPath].append(changes)
    print(newObject[keyPath: keyPath])
}

class BaseTestCase: XCTestCase {

    var encoder: JSONEncoder = {
        var encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()

    var decoder: JSONDecoder = {
        var decoder = JSONDecoder()
        return decoder
    }()

    func run(file: StaticString = #file, line: UInt = #line, execute body: () throws -> Void) {
        do {
            try body()
        } catch {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }

}
