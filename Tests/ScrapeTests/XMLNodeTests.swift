//
//  XMLNodeTests.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 17.09.16.
//
//

import Foundation
import Scrape
import XCTest

final class XMLNodeTests: XCTestCase {
    
    static let allTests = {
        return [
            ("testGetText", testGetText),
            ("testGetHTML", testGetHTML),
            ("testGetXML", testGetXML),
            ("testGetInnerHTML", testGetInnerHTML),
            ("testGetClassName", testGetClassName),
            ("testGetSetTagName", testGetSetTagName),
            ("testGetSetContent", testGetSetContent),
            ("testGetSetSubscript", testGetSetSubscript),
            ("testGetSetParent", testGetSetParent),
            ("testRemoveChild", testRemoveChild)
        ]
    }()
    
    var document: HTMLDocument!
    
    override func setUp() {
        super.setUp()
        
        guard let htmlExampleData = getTestingResource(fromFile: "HTMLExample", ofType: "html") else {
            XCTFail("Could not find a testing resource")
            return
        }
        
        guard let document = HTMLDocument(html: htmlExampleData, encoding: .utf8, options: .strict) else {
            XCTFail("Could not initialize an HTMLDocument instance")
            return
        }
        
        self.document = document
    }
    
    // MARK: - Read-only properties
    
    func testGetText() {
        
        // Given
        guard let node = document.atXPath("//div[@id='farewell']") as? Scrape.XMLNode else {
            XCTFail("Could not get an XML node from the document")
            return
        }
        
        let expectedText = "Bye!"
        
        // When
        let returnedText = node.text
        
        // Then
        XCTAssertEqual(expectedText, returnedText)
    }
    
    func testGetHTML() {
        
        // Given
        guard let node = document.atXPath("//thead") as? Scrape.XMLNode else {
            XCTFail("Could not get an XML node from the document")
            return
        }
        
        let expectedHTML =
            "<thead>\n        <tr>\n<th>Name</th>\n<th>Stars</th>\n</tr>\n      </thead>"
        
        // When
        let returnedHTML = node.html
        
        // Then
        XCTAssertEqual(expectedHTML, returnedHTML)
    }
    
    func testGetXML() {
        
        // Given
        guard let node = document.atXPath("//thead") as? Scrape.XMLNode else {
            XCTFail("Could not get an XML node from the document")
            return
        }
        
        let expectedXML =
            "<thead>\n        <tr><th>Name</th><th>Stars</th></tr>\n      </thead>"
        
        // When
        let returnedXML = node.xml
        
        // Then
        XCTAssertEqual(expectedXML, returnedXML)
    }
    
    func testGetInnerHTML() {
        
        // Given
        guard let node = document.atXPath("//thead") as? Scrape.XMLNode else {
            XCTFail("Could not get an XML node from the document")
            return
        }
        
        let expectedInnerHTML = "\n        <tr>\n<th>Name</th>\n<th>Stars</th>\n</tr>\n      "
        
        // When
        let returnedInnerHTML = node.innerHTML
        
        // Then
        XCTAssertEqual(expectedInnerHTML, returnedInnerHTML)
    }
    
    func testGetClassName() {
        
        // Given
        guard let nodeWithClass = document
            .atXPath("//a[@href='http://github.com/jessesquires/JSQCoreDataKit']"),
            let nodeWithoutClass = document.atXPath("//head") as? Scrape.XMLNode else {
                
            XCTFail("Could not get an XML node from the document")
            return
        }
        
        let expectedClassNameForNodeWithClass = "mini-repo-list-item css-truncate"
        
        // When
        let returnedClassNameForNodeWithClass = nodeWithClass.className
        let returnedClassNameForNodeWithoutClass = nodeWithoutClass.className
        
        // Then
        XCTAssertEqual(expectedClassNameForNodeWithClass, returnedClassNameForNodeWithClass)
        XCTAssertNil(returnedClassNameForNodeWithoutClass)
    }
    
    // MARK: - Settable properties
    
    func testGetSetTagName() {
        
        // Given
        guard let node = document.atXPath("//*[@id='farewell']") as? Scrape.XMLNode else {
            XCTFail("Could not get an XML node from the document")
            return
        }
        
        let expectedTagName = "div"
        let expectedModifiedNodeXML = "<Tag1 id=\"farewell\">Bye!</Tag1>"
        
        // When
        let returnedTagName = node.tagName
        
        // Then
        XCTAssertEqual(expectedTagName, returnedTagName)
        
        // When
        node.tagName = "Tag1\n<;\"\""
        let returnedModifiedNodeXML = node.xml
        
        // Then
        XCTAssertEqual(expectedModifiedNodeXML, returnedModifiedNodeXML)
        
        // When
        node.tagName = nil
        let renutnedModifiedNodeWithDeletedTagXML = node.xml
        
        // Then
        XCTAssertEqual(expectedModifiedNodeXML, renutnedModifiedNodeWithDeletedTagXML)
    }
    
    func testGetSetContent() {
        
        // Given
        guard let node = document.atXPath("//*[@id='farewell']") as? Scrape.XMLNode else {
            XCTFail("Could not get an XML node from the document")
            return
        }
        
        let expectedContent = "Bye!"
        let expectedModifiedNodeXML = "<div id=\"farewell\">Tschüss!\n&lt;escaped&gt;</div>"
        let expectedModifiedNodeWithDeletedContentXML = "<div id=\"farewell\"/>"
        
        // When
        let returnedContent = node.content
        
        // Then
        XCTAssertEqual(expectedContent, returnedContent)
        
        // When
        node.content = "Tschüss!\n<escaped>"
        let returnedModifiedNodeXML = node.xml
        
        // Then
        XCTAssertEqual(expectedModifiedNodeXML, returnedModifiedNodeXML)
        
        // When
        node.content = nil
        let renurnedModifiedNodeWithDeletedContentXML = node.xml
        
        // Then
        XCTAssertEqual(expectedModifiedNodeWithDeletedContentXML, renurnedModifiedNodeWithDeletedContentXML)
    }
    
    func testGetSetSubscript() {
        
        // Given
        guard let node = document.search(byXPath: "//span[@class='repo']").first as? Scrape.XMLNode else {
            XCTFail("Could not get an XML node from the document")
            return
        }
        
        let expectedTitleAttributeValue = "JSQCoreDataKit"
        let expectedModifiedNodeXML = "<span class=\"repo\" title=\"JSQ\">JSQCoreDataKit</span>"
        let expectedModifiedNodeWithDeletedAttributeXML = "<span class=\"repo\">JSQCoreDataKit</span>"
        
        // When
        let returnedTitleAttributeValue = node["title"]
        
        // Then
        XCTAssertEqual(expectedTitleAttributeValue, returnedTitleAttributeValue)
        
        // When
        node["title"] = "JSQ"
        let returnedModifiedNodeXML = node.xml
        
        // Then
        XCTAssertEqual(expectedModifiedNodeXML, returnedModifiedNodeXML)
        
        // When
        node["title"] = nil
        let returnedModifiedNodeWithDeletedAttributeXML = node.xml
        
        // Then
        XCTAssertEqual(expectedModifiedNodeWithDeletedAttributeXML, returnedModifiedNodeWithDeletedAttributeXML)
    }
    
    // MARK: - Modifying nodes layout
    
    func testGetSetParent() {
        
        // Given
        guard let repoNode = document.search(byXPath: "//span[@class='repo']").first as? Scrape.XMLNode,
            let starsNode = repoNode.atXPath("following-sibling::*[1]") as? Scrape.XMLNode else {
            XCTFail("Could not get an XML node from the document")
            return
        }
        
        let expectedParentNodeXML =
        "<a href=\"http://github.com/jessesquires/JSQCoreDataKit\" class=\"mini-repo-list-item css-truncate\">\n" +
        "            <span class=\"repo\" title=\"JSQCoreDataKit\">JSQCoreDataKit</span>\n" +
        "            <span class=\"stars\">\n" +
        "              357\n" +
        "              <span class=\"oction oction-star\"/>\n" +
        "            </span>\n" +
        "            <span class=\"repo-description css-truncate-target\">A swifter Core Data stack</span>\n" +
        "          </a>"
        
        let expectedModifiedRepoNodeXML =
        "<span class=\"repo\" title=\"JSQCoreDataKit\">JSQCoreDataKit<span class=\"stars\">\n" +
        "              357\n" +
        "              <span class=\"oction oction-star\"/>\n" +
        "            </span></span>"
        
        // When
        let returnedParentNodeXML = repoNode.parent?.xml
        
        // Then
        XCTAssertEqual(expectedParentNodeXML, returnedParentNodeXML)
        
        // When
        starsNode.parent = repoNode
        let returnedModifiedRepoNodeXML = repoNode.xml
        
        // Then
        XCTAssertEqual(expectedModifiedRepoNodeXML, returnedModifiedRepoNodeXML)
    }
    
    func testRemoveChild() {
        
        // Given
        guard let parent = document.search(byXPath: "//span[@class='stars']").first as? Scrape.XMLNode,
            let child = parent.atXPath("descendant::*[1]") as? Scrape.XMLNode else {
                XCTFail("Could not get an XML node from the document")
                return
        }
        
        let expectedParentXML = "<span class=\"stars\">\n" +
        "              357\n" +
        "              \n" +
        "            </span>"
        
        // When
        parent.removeChild(child)
        let actualParentXML = parent.xml
        
        // Then
        XCTAssertEqual(expectedParentXML, actualParentXML)
    }
}
