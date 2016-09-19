//
//  XMLDocumentTests.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 16.09.16.
//
//

import Foundation
import Scrape
import XCTest

final class XMLDocumentTests: XCTestCase {
    
    static let allTests = {
        return [
            ("testLoadXMLFromData", testLoadXMLFromData),
            ("testLoadXMLFromString", testLoadXMLFromString),
            ("testLoadXMLFromURL", testLoadXMLFromURL),
            ("testLoadXMLWithDifferentEncoding", testLoadXMLWithDifferentEncoding),
            ("testLoadXMLWithParsingOptions", testLoadXMLWithParsingOptions),
            ("testXPathTagQuery", testXPathTagQuery),
            ("testXPathTagQueryWithNamespaces", testXPathTagQueryWithNamespaces),
            ("testAddingAsPreviousSibling", testAddingAsPreviousSibling)
            ]
    }()
    
    private struct Seeds {
        
        static let xmlString = "<?xml version=\"1.0\"?><all_item><item><title>item0</title></item>" +
            "<item><title>item1</title></item></all_item>"
        
        static let allVersions = ["iOS 10", "iOS 9", "iOS 8", "macOS 10.12", "macOS 10.11", "tvOS 10.0"]
        static let iosVersions = ["iOS 10", "iOS 9", "iOS 8"]
        static let tvOSVErsion = "tvOS 10.0"
        
        static let librariesGithub = ["Scrape", "SwiftyJSON"]
        static let librariesBitbucket = ["Hoge"]
    }
    
    // MARK: - Test loading
    
    func testLoadXMLFromData() {
        
        // Given
        guard let correctData = getTestingResource(fromFile: "Versions", ofType: "xml") else {
            XCTFail("Could not find a testing resource")
            return
        }
        
        let incorrectData = "💩".data(using: .utf32LittleEndian)!
        
        // When
        let documentFromCorrectData = XMLDocument(xml: correctData, encoding: .utf8)
        let documentFromIncorrectData = XMLDocument(xml: incorrectData, encoding: .utf8)
        
        // Then
        XCTAssertNotNil(documentFromCorrectData, "XMLDocument should be initialized from correct Data")
        XCTAssertNil(documentFromIncorrectData, "XMLDocument should not be initialized from incorrect Data")
    }
    
    func testLoadXMLFromString() {
        
        // Given
        let correctString = Seeds.xmlString
        let incorrectString = "a><"
        
        // When
        let documentFromCorrectString = XMLDocument(xml: correctString, encoding: .utf8)
        let documentFromIncorrectString = XMLDocument(xml: incorrectString, encoding: .utf8)
        
        // Then
        XCTAssertNotNil(documentFromCorrectString, "XMLDocument should be initialized from a correct string")
        XCTAssertNil(documentFromIncorrectString, "XMLDocument should not be initialized from an incorrect string")
    }
    
    func testLoadXMLFromURL() {
        
        // Given
        guard let correctURL = getURLForTestingResource(forFile: "Versions", ofType: "xml") else {
            XCTFail("Could not find a testing resource")
            return
        }
        
        let incorrectURL = URL(fileURLWithPath: "42")
        
        // When
        let documentFromCorrectURL = XMLDocument(url: correctURL, encoding: .utf8)
        let documentFromIncorrectURL = XMLDocument(url: incorrectURL, encoding: .utf8)
        
        // Then
        XCTAssertNotNil(documentFromCorrectURL, "XMLDocument should be initialized from a correct URL")
        XCTAssertNil(documentFromIncorrectURL, "XMLDocument should not be initialized from an incorrect URL")
    }
    
    func testLoadXMLWithDifferentEncoding() {
        
        // Given
        let xmlString = Seeds.xmlString
        
        // When
        let document = XMLDocument(xml: xmlString, encoding: .japaneseEUC)
        
        // Then
        XCTAssertNotNil(document, "XMLDocument should be initialized even with an encoding other than UTF8")
    }
    
    func testLoadXMLWithParsingOptions() {
        
        // Given
        let xmlString = Seeds.xmlString
        
        // When
        let document = XMLDocument(xml: xmlString, encoding: .utf8, options: [.huge, .bigLines])
        
        // Then
        XCTAssertNotNil(document, "XMLDocument should be initialized even with options other than default")
    }
    
    // MARK: - Test XPath queries
    
    func testXPathTagQuery() {
        
        // Given
        guard let versionsData = getTestingResource(fromFile: "Versions", ofType: "xml") else {
            XCTFail("Could not find a testing resource")
            return
        }
        
        guard let document = XMLDocument(xml: versionsData, encoding: .utf8) else {
            XCTFail("Could not initialize an XMLDocument instance")
            return
        }
        
        let expectedVersionsForTagName = Seeds.allVersions
        let expectedVersionsForTagsIOSName = Seeds.iosVersions

        // When
        let returnedVersionsForTagName = document.search(byXPath: "//name").map { $0.text ?? "" }
        let returnedVersionsForTagsIOSName = document.search(byXPath: "//ios//name").map { $0.text ?? "" }
        
        // Then
        XCTAssertEqual(expectedVersionsForTagName, returnedVersionsForTagName)
        XCTAssertEqual(expectedVersionsForTagsIOSName, returnedVersionsForTagsIOSName)
    }
    
    func testXPathTagQueryWithNamespaces() {
        
        // Given
        guard let librariesData = getTestingResource(fromFile: "Libraries", ofType: "xml") else {
            XCTFail("Could not find a testing resource")
            return
        }
        
        guard let document = XMLDocument(xml: librariesData, encoding: .utf8) else {
            XCTFail("Could not initialize an XMLDocument instance")
            return
        }
        
        let expectedValuesInGithubNamespace = Seeds.librariesGithub
        let expectedValuesInBitbucketNamespace = Seeds.librariesBitbucket
        
        // When
        let returnedValuesInGithubNamespace = document
            .search(byXPath: "//github:title", namespaces: ["github" : "https://github.com/"])
            .map { $0.text ?? "" }
        
        let returnedValuesInBitbucketNamespace = document
            .search(byXPath: "//bitbucket:title", namespaces: ["bitbucket": "https://bitbucket.org/"])
            .map { $0.text ?? "" }
        
        // Then
        XCTAssertEqual(expectedValuesInGithubNamespace, returnedValuesInGithubNamespace)
        XCTAssertEqual(expectedValuesInBitbucketNamespace, returnedValuesInBitbucketNamespace)
    }
    
    func testAddingAsPreviousSibling() {
        
        // Given
        
        // Before:
        //
        // <all_item>
        //   <item>
        //     <title>item0</title>
        //   </item>
        //   <item>
        //     <title>item1</title>
        //   </item>
        // </all_item>
        
        let initialXML = Seeds.xmlString
        
        guard let document = XMLDocument(xml: initialXML, encoding: .utf8) else {
            XCTFail("Could not initialize an XMLDocument instance")
            return
        }

        // After:
        //
        // <all_item>
        //   <item>
        //     <title>item1</title>
        //   </item>
        //   <item>
        //     <title>item0</title>
        //   </item>
        // </all_item>
        
        let expectedModifiedXML = "<all_item><item><title>item1</title></item>" +
        "<item><title>item0</title></item></all_item>"
        
        // When
        let searchResult = document.search(byXPath: "//item")
        let item0 = searchResult[0]
        let item1 = searchResult[1]
        
        item0.addPreviousSibling(item1)
        
        let actualModifiedXML = document.atXPath("//all_item")?.xml
        
        // Then
        XCTAssertEqual(expectedModifiedXML, actualModifiedXML)
    }
    
    func testAddingAsNextSibling() {
        
        // Given
        
        // Before:
        //
        // <all_item>
        //   <item>
        //     <title>item0</title>
        //   </item>
        //   <item>
        //     <title>item1</title>
        //   </item>
        // </all_item>
        
        let initialXML = Seeds.xmlString
        
        guard let document = XMLDocument(xml: initialXML, encoding: .utf8) else {
            XCTFail("Could not initialize an XMLDocument instance")
            return
        }
        
        // After:
        //
        // <all_item>
        //   <item>
        //     <title>item1</title>
        //   </item>
        //   <item>
        //     <title>item0</title>
        //   </item>
        // </all_item>
        
        let expectedModifiedXML = "<all_item><item><title>item1</title></item>" +
        "<item><title>item0</title></item></all_item>"
        
        // When
        let searchResult = document.search(byXPath: "//item")
        let item0 = searchResult[0]
        let item1 = searchResult[1]
        
        item1.addNextSibling(item0)
        
        let actualModifiedXML = document.atXPath("//all_item")?.xml
        
        // Then
        XCTAssertEqual(expectedModifiedXML, actualModifiedXML)
    }
    
    // MARK: - Test CSS selector queries
    
    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    func testCSSSelectorTagQuery() {
        
        // Given
        guard let versionsData = getTestingResource(fromFile: "Versions", ofType: "xml") else {
            XCTFail("Could not find a testing resource")
            return
        }
        
        guard let document = XMLDocument(xml: versionsData, encoding: .utf8) else {
            XCTFail("Could not initialize an XMLDocument instance")
            return
        }
        
        let expectedVersionsForTagsIOSName = Seeds.iosVersions
        let expectedVersionForTagsTVOSName = Seeds.tvOSVErsion
        
        // When
        let returnedVersionsForTagsIOSName = document.search(byCSSSelector: "ios name").map { $0.text ?? "" }
        let returnedVersionForTagsTVOSName = document.atCSSSelector("tvos name")?.text
        
        // Then
        XCTAssertEqual(expectedVersionsForTagsIOSName, returnedVersionsForTagsIOSName)
        XCTAssertEqual(expectedVersionForTagsTVOSName, returnedVersionForTagsTVOSName)
    }
    #endif
}
