//
//  KannaTutorialsTest.swift
//  Kanna
//
//  Created by Atsushi Kiwaki on 6/27/16.
//  Copyright © 2016 tid. All rights reserved.
//
import XCTest
@testable import Scrape

class KannaTutorialsTests: XCTestCase {
    func testParsingFromString() {
        let html = "<html><body><h1>Tutorials</h1></body></html>"
        if let htmlDoc = HTML(html: html, encoding: String.Encoding.utf8.rawValue) {
            XCTAssert(htmlDoc.html != nil)
        }
        
        let xml = "<root><item><name>Tutorials</name></item></root>"
        if let xmlDoc = XML(xml: xml, encoding: String.Encoding.utf8.rawValue) {
            XCTAssert(xmlDoc.html != nil)
        }
        
    }
    
    func testParsingFromFile() {
        let filename = "test_HTML4"
        guard let filePath = Bundle(for: self.classForCoder).path(forResource: filename, ofType: "html") else {
            return
        }
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
        if let doc = HTML(html: data, encoding: String.Encoding.utf8.rawValue) {
            XCTAssert(doc.html != nil)
        }
        
        let html = try! String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        if let doc = HTML(html: html, encoding: String.Encoding.utf8.rawValue) {
            XCTAssert(doc.html != nil)
        }
    }
    
    func testParsingFromInternets() {
        let url = URL(string: "https://en.wikipedia.org/wiki/Cat")
        if let doc = HTML(url: url!, encoding: String.Encoding.utf8.rawValue) {
            XCTAssert(doc.html != nil)
        }
    }
    
    func testParsingFromEncoding() {
        let html = "<html><body><h1>Tutorials</h1></body></html>"
        if let htmlDoc = HTML(html: html, encoding: String.Encoding.japaneseEUC.rawValue) {
            XCTAssert(htmlDoc.html != nil)
        }
    }
    
    func testParsingOptions() {
        let html = "<html><body><h1>Tutorials</h1></body></html>"
        
        if let doc = HTML(html: html, encoding: String.Encoding.utf8.rawValue, option: .html(.strict)) {
            XCTAssert(doc.html != nil)
        }
    }
    
    func testSearchingBasicSearching() {
        let TestVersionData = [
            "iOS 10",
            "iOS 9",
            "iOS 8",
            "macOS 10.12",
            "macOS 10.11",
            "tvOS 10.0",
            ]
        
        let TestVersionDataIOS = [
            "iOS 10",
            "iOS 9",
            "iOS 8",
            ]
        let filename = "versions"
        guard let filePath = Bundle(for: self.classForCoder).path(forResource: filename, ofType:"xml") else {
            return
        }
        let xml = try! String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        if let doc = XML(xml: xml, encoding: String.Encoding.utf8.rawValue) {
            for (i, node) in doc.search(byXPath: "//name").enumerated() {
                XCTAssert(node.text! == TestVersionData[i])
            }
            
            let nodes = doc.search(byXPath: "//name")
            XCTAssert(nodes[0].text! == TestVersionData[0])
            
            for (i, node) in doc.search(byXPath: "//ios//name").enumerated() {
                XCTAssert(node.text! == TestVersionDataIOS[i])
            }
            
            for (i, node) in doc.search(byCSSSelector: "ios name").enumerated() {
                XCTAssert(node.text! == TestVersionDataIOS[i])
            }
            
            XCTAssertEqual(doc.search(byCSSSelector: "tvos name").first!.text, "tvOS 10.0")
            XCTAssertEqual(doc.atCSSSelector("tvos name")?.text, "tvOS 10.0")
        }
    }
    
    func testSearchingNamespaces() {
        let TestLibrariesDataGitHub = [
            "Kanna",
            "Alamofire",
            ]
        
        let TestLibrariesDataBitbucket = [
            "Hoge",
            ]
        
        let filename = "libraries"
        guard let filePath = Bundle(for: self.classForCoder).path(forResource: filename, ofType:"xml") else {
            return
        }
        
        let xml = try! String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        if let doc = XML(xml: xml, encoding: String.Encoding.utf8.rawValue) {
            
            for (i, node) in doc.search(byXPath: "//github:title",
                                        namespaces: ["github" : "https://github.com/"]).enumerated() {
                XCTAssert(node.text! == TestLibrariesDataGitHub[i])
            }
        }
        
        if let doc = XML(xml: xml, encoding: String.Encoding.utf8.rawValue) {
            
            for (i, node) in doc.search(byXPath: "//bitbucket:title",
                                        namespaces: ["bitbucket": "https://bitbucket.org/"]).enumerated() {
                                            XCTAssert(node.text! == TestLibrariesDataBitbucket[i])
            }
        }
    }
    
    func testModifyingChangingTextContents() {
        let TestModifyHTML = "<body>\n    <h1>Snap, Crackle &amp; Pop</h1>\n    <div>A love triangle.</div>\n</body>"
        let filename = "sample"
        guard let filePath = Bundle(for:self.classForCoder).path(forResource: filename, ofType:"html") else {
            return
        }
        
        
        let html = try! String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        guard let doc = HTML(html: html, encoding: String.Encoding.utf8.rawValue) else {
            return
        }
        
        var h1 = doc.atCSSSelector("h1")!
        h1.content = "Snap, Crackle & Pop"
        
        XCTAssert(doc.body?.html == TestModifyHTML)
    }
    
    func testModifyingMovingNode() {
        let TestModifyHTML = "<body>\n    \n    <div>A love triangle.<h1>Three\'s Company</h1>\n</div>\n</body>"
        let TestModifyArrangeHTML = "<body>\n    \n    <div>A love triangle.</div>\n<h1>Three\'s Company</h1>\n</body>"
        let filename = "sample"
        guard let filePath = Bundle(for:self.classForCoder).path(forResource: filename, ofType:"html") else {
            return
        }
        let html = try! String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        guard let doc = HTML(html: html, encoding: String.Encoding.utf8.rawValue) else {
            return
        }
        var h1  = doc.atCSSSelector("h1")!
        let div = doc.atCSSSelector("div")!
        
        h1.parent = div
        
        XCTAssert(doc.body!.html == TestModifyHTML)
        
        div.addNextSibling(h1)
        
        XCTAssert(doc.body!.html == TestModifyArrangeHTML)
    }
    
    func testModifyingNodesAndAttributes() {
        let TestModifyHTML = "<body>\n    <h2 class=\"show-title\">Three\'s Company</h2>\n    <div>A love triangle.</div>\n</body>"
        let filename = "sample"
        guard let filePath = Bundle(for:self.classForCoder).path(forResource: filename, ofType:"html") else {
            return
        }
        let html = try! String(contentsOfFile: filePath, encoding: String.Encoding.utf8)
        guard let doc = HTML(html: html, encoding: String.Encoding.utf8.rawValue) else {
            return
        }
        var h1  = doc.atCSSSelector("h1")!
        
        h1.tagName = "h2"
        h1["class"] = "show-title"
        
        XCTAssert(doc.body?.html == TestModifyHTML)
    }
}
