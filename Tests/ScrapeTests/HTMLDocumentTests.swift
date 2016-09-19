//
//  HTMLDocumentTests.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 17.09.16.
//
//

import Foundation
import Scrape
import XCTest

class HTMLDocumentTests: XCTestCase {
    
    static let allTests = {
        return [
            ("testLoadHTMLFromData", testLoadHTMLFromData),
            ("testLoadHTMLFromString", testLoadHTMLFromString),
            ("testLoadHTMLFromURL", testLoadHTMLFromURL),
            ("testLoadHTMLWithDifferentEncoding", testLoadHTMLWithDifferentEncoding),
            ("testLoadHTMLWithParsingOptions", testLoadHTMLWithParsingOptions),
            ("testHTMLGetHead", testHTMLGetHead),
            ("testHTMLGetTitle", testHTMLGetTitle),
            ("testXPathTagWithAttributeQuery", testXPathTagWithAttributeQuery),
            ("testXPathResultScalarValues", testXPathResultScalarValues)
        ]
    }()
    
    private struct Seeds {
        
        static let htmlString = "<html><body><h1>Tutorials</h1></body></html>"
        
        static let htmlExampleHead =
            "<head>\n" +
        "    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n" +
        "    <meta http-equiv=\"Content-Style-Type\" content=\"text/css\">\n" +
        "    <meta http-equiv=\"content-script-type\" content=\"text/javascript\">\n" +
        "    <meta name=\"description\" content=\"page description\">\n" +
        "    <meta name=\"keywords\" content=\"keyword01,keyword02\">\n" +
        "    <link rev=\"made\" href=\"mailto:johnsmith@example.com\">\n" +
        "    <link rel=\"index\" href=\"./index.html\">\n" +
        "    <title>HTMLExample</title>\n" +
        "  </head>"
        
        static let htmlExampleTitle = "HTMLExample"
        
        static let linkURLAddresses = ["mailto:johnsmith@example.com", "./index.html"]
        
        static let numberOfRowsInTable = 10
        static let numberOfColumnsInTable = 3
        
        static let xpathBoolValue = XPathResult.bool(true)
        static let xpathNumberValue = XPathResult.number(123)
        static let xpathStringValue = XPathResult.string("http://github.com/jessesquires/JSQCoreDataKit" +
            "http://github.com/libharu/libharu")
    }
    
    // MARK: - Loading
    
    func testLoadHTMLFromData() {
        
        // Given
        guard let correctData = getTestingResource(fromFile: "HTMLExample", ofType: "html") else {
            XCTFail("Could not find a testing resource")
            return
        }
        
        let incorrectData = "💩".data(using: .utf32)!
        
        // When
        let documentFromCorrectData = HTMLDocument(html: correctData, encoding: .utf8)
        let documentFromIncorrectData = HTMLDocument(html: incorrectData, encoding: .utf8)
        
        // Then
        XCTAssertNotNil(documentFromCorrectData, "HTMLDocument should be initialized from correct Data")
        XCTAssertNil(documentFromIncorrectData, "HTMLDocument should not be initialized from incorrect Data")
    }
    
    func testLoadHTMLFromString() {
        
        // Given
        let correctString = Seeds.htmlString
        let incorrectString = ""
        
        // When
        let documentFromCorrectString = HTMLDocument(html: correctString, encoding: .utf8)
        let documentFromIncorrectString = HTMLDocument(html: incorrectString, encoding: .utf8)
        
        // Then
        XCTAssertNotNil(documentFromCorrectString, "HTMLDocument should be initialized from a correct string")
        XCTAssertNil(documentFromIncorrectString, "HTMLDocument should not be initialized from an incorrect string")
    }
    
    func testLoadHTMLFromURL() {
        
        // Given
        guard let correctURL = getURLForTestingResource(forFile: "HTMLExample", ofType: "html") else {
            XCTFail("Could not find a testing resource")
            return
        }
        
        let incorrectURL = URL(fileURLWithPath: "42")
        
        // When
        let documentFromCorrectURL = HTMLDocument(url: correctURL, encoding: .utf8)
        let documentFromIncorrectURL = HTMLDocument(url: incorrectURL, encoding: .utf8)
        
        // Then
        XCTAssertNotNil(documentFromCorrectURL, "HTMLDocument should be initialized from a correct URL")
        XCTAssertNil(documentFromIncorrectURL, "HTMLDocument should not be initialized from an incorrect URL")
    }
    
    func testLoadHTMLWithDifferentEncoding() {
        
        // Given
        let htmlString = Seeds.htmlString
        
        // When
        let document = HTMLDocument(html: htmlString, encoding: .japaneseEUC)
        
        // Then
        XCTAssertNotNil(document, "HTMLDocument should be initialized even with an encoding other than UTF8")
    }
    
    func testLoadHTMLWithParsingOptions() {
        
        // Given
        let htmlString = Seeds.htmlString
        
        // When
        let document = XMLDocument(xml: htmlString, encoding: .utf8, options: [.cleanNamespace, .compact])
        
        // Then
        XCTAssertNotNil(document, "HTMLDocument should be initialized even with ptions other than default")
    }
    
    // MARK: - HTMLDocument properties
    
    func testHTMLGetHead() {
        
        // Given
        guard let htmlExampleData = getTestingResource(fromFile: "HTMLExample", ofType: "html") else {
            XCTFail("Could not find a testing resource")
            return
        }
        
        guard let document = HTMLDocument(html: htmlExampleData, encoding: .utf8) else {
            XCTFail("Could not initialize an HTMLDocument instance")
            return
        }
        
        let expectedHead = Seeds.htmlExampleHead
        
        // When
        let returnedHead = document.head?.html
        
        // Then
        XCTAssertEqual(expectedHead, returnedHead)
    }
    
    func testHTMLGetTitle() {
        
        // Given
        guard let htmlExampleData = getTestingResource(fromFile: "HTMLExample", ofType: "html") else {
            XCTFail("Could not find a testing resource")
            return
        }
        
        guard let document = HTMLDocument(html: htmlExampleData, encoding: .utf8) else {
            XCTFail("Could not initialize an HTMLDocument instance")
            return
        }
        
        let expectedTitle = Seeds.htmlExampleTitle
        
        // When
        let returnedTitle = document.title
        
        // Then
        XCTAssertEqual(expectedTitle, returnedTitle)
    }
    
    // MARK: - XPath queries
    
    func testXPathTagWithAttributeQuery() {
        
        // Given
        guard let htmlExampleData = getTestingResource(fromFile: "HTMLExample", ofType: "html") else {
            XCTFail("Could not find a testing resource")
            return
        }
        
        guard let document = HTMLDocument(html: htmlExampleData, encoding: .utf8) else {
            XCTFail("Could not initialize an HTMLDocument instance")
            return
        }
        
        let expectedURLAddressesForTagLink = Seeds.linkURLAddresses
        
        // When
        let returnedURLAddressesForTagLink = document.search(byXPath: "//link").map { $0["href"] ?? "" }
        
        // Then
        XCTAssertEqual(expectedURLAddressesForTagLink, returnedURLAddressesForTagLink)
    }
    
    func testXPathResultScalarValues() {
        
        // Given
        guard let htmlExampleData = getTestingResource(fromFile: "HTMLExample", ofType: "html") else {
            XCTFail("Could not find a testing resource")
            return
        }
        
        guard let document = HTMLDocument(html: htmlExampleData, encoding: .utf8) else {
            XCTFail("Could not initialize an HTMLDocument instance")
            return
        }
        
        let expectedBoolValue = Seeds.xpathBoolValue
        let expectedNumberValue = Seeds.xpathNumberValue
        let expectedStringValue = Seeds.xpathStringValue
        
        // When
        let returnedBoolValue = document.search(byXPath: "true()")
        let returnedNumberValue = document.search(byXPath: "number(123)")
        let returnedStringValue = document.search(byXPath: "concat((//a/@href)[1], (//a/@href)[2])")
        
        // Then
        XCTAssertEqual(expectedBoolValue, returnedBoolValue)
        XCTAssertEqual(expectedNumberValue, returnedNumberValue)
        XCTAssertEqual(expectedStringValue, returnedStringValue)
    }
    
    // MARK: - CSS selector queries
    
    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    func testCSSSelectorTagWithAttributeQuery() {
        
        // Given
        guard let htmlExampleData = getTestingResource(fromFile: "HTMLExample", ofType: "html") else {
            XCTFail("Could not find a testing resource")
            return
        }
        
        guard let document = HTMLDocument(html: htmlExampleData, encoding: .utf8) else {
            XCTFail("Could not initialize an HTMLDocument instance")
            return
        }
        
        let expectedNumberOfRows = Seeds.numberOfRowsInTable
        let expectedNumberOfColumns = Seeds.numberOfColumnsInTable
        
        // When
        
        let table = document.atCSSSelector("#sequence-number")
        let actualNumberOfRows = table?.search(byCSSSelector: "tr").count
        let actualNumberOfColumns = table?.atCSSSelector("tr")?.search(byCSSSelector: "td").count
        
        // Then
        XCTAssertEqual(expectedNumberOfRows, actualNumberOfRows)
        XCTAssertEqual(expectedNumberOfColumns, actualNumberOfColumns)
    }
    #endif
}
