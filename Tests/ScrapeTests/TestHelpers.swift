//
//  TestHelpers.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 16.09.16.
//
//

import Foundation
import XCTest

extension XCTestCase {
    
    func getURLForTestingResource(forFile file: String, ofType type: String?) -> URL? {
        return URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent(file + (type == nil ? "" : "." + type!))
    }
    
    func getTestingResource(fromFile file: String, ofType type: String?) -> Data? {
        
        guard let url = getURLForTestingResource(forFile: file, ofType: type) else { return nil }
        
        return try? Data(contentsOf: url)
    }
    
    func getTestingResourceAsString(fromFile file: String, ofType type: String?) -> String? {
        
        guard let data = getTestingResource(fromFile: file, ofType: type) else { return nil }
        
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            return String(data: data, encoding: .utf8)
        #else
            return data.withUnsafeBytes { (pointer: UnsafePointer<CChar>) -> String in String(cString: pointer) }
        #endif
    }
}
