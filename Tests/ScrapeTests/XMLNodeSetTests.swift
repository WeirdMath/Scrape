//
//  XMLNodeSetTests.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 19.09.16.
//
//

import Foundation
import Scrape
import XCTest

final class XMLNodeSetTests: XCTestCase {
    
    static let allTests = {
        return [
            ("testGetHTML", testGetHTML),
            ("testGetXML", testGetXML),
            ("testGetInnerHTML", testGetInnerHTML),
            ("testGetText", testGetText)
        ]
    }()
    
    var document: HTMLDocument!
    
    override func setUp() {
        super.setUp()
        
        guard let htmlExampleData = getTestingResource(fromFile: "HTMLExample", ofType: "html") else {
            XCTFail("Could not find a testing resource")
            return
        }
        
        guard let document = HTMLDocument(html: htmlExampleData, encoding: .utf8) else {
            XCTFail("Could not initialize an HTMLDocument instance")
            return
        }
        
        self.document = document
    }
    
    func testGetHTML() {
        
        // Given
        guard case .nodeSet(let nodeSet) = document.search(byXPath: "//meta") else {
            XCTFail("Could not get a node set")
            return
        }
        
        let expectedHTML = "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">" +
            "<meta http-equiv=\"Content-Style-Type\" content=\"text/css\">" +
            "<meta http-equiv=\"content-script-type\" content=\"text/javascript\">" +
            "<meta name=\"description\" content=\"page description\">" +
        "<meta name=\"keywords\" content=\"keyword01,keyword02\">"
        
        // When
        let returnedHTML = nodeSet.html
        
        // Then
        XCTAssertEqual(expectedHTML, returnedHTML)
    }
    
    func testGetXML() {
        
        // Given
        guard case .nodeSet(let nodeSet) = document.search(byXPath: "//meta") else {
            XCTFail("Could not get a node set")
            return
        }
        
        let expectedXML = "<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"/>" +
            "<meta http-equiv=\"Content-Style-Type\" content=\"text/css\"/>" +
            "<meta http-equiv=\"content-script-type\" content=\"text/javascript\"/>" +
            "<meta name=\"description\" content=\"page description\"/>" +
        "<meta name=\"keywords\" content=\"keyword01,keyword02\"/>"
        
        // When
        let returnedXML = nodeSet.xml
        
        // Then
        XCTAssertEqual(expectedXML, returnedXML)
    }
    
    func testGetInnerHTML() {
        
        // Given
        guard case .nodeSet(let nodeSet) = document.search(byXPath: "//span[@class='stars']") else {
            XCTFail("Could not get a node set")
            return
        }
        
        let expectedInnerHTML = "\n              357\n" +
            "              <span class=\"oction oction-star\"></span>\n            " +
        "\n              503\n              <span class=\"oction oction-star\"></span>\n            "
        
        // When
        let returnedInnerHTML = nodeSet.innerHTML
        
        // Then
        XCTAssertEqual(expectedInnerHTML, returnedInnerHTML)
    }
    
    func testGetText() {
        
        // Given
        guard case .nodeSet(let nodeSet) = document.search(byXPath: "//span[@class='stars']") else {
            XCTFail("Could not get a node set")
            return
        }
        
        let expectedText = "\n              357\n              \n            " +
        "\n              503\n              \n            "
        
        // When
        let returnedText = nodeSet.text
        
        // Then
        XCTAssertEqual(expectedText, returnedText)
    }
}
