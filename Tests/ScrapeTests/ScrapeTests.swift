/**@file KannaTests.swift
 
 Kanna
 
 @Copyright (c) 2015 Atsushi Kiwaki (@_tid_)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import XCTest
import Foundation
@testable import Scrape


class ScrapeTests: XCTestCase {
    
    static var allTests = {
        return [
            ("testHTML4", testHTML4),
        ]
    }()
    
    /**
     test HTML4
     */
    func testHTML4() {
        // This is an example of a functional test case.
        let filename = "test_HTML4.html"
        let filePath = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent(filename)
        
        do {
            let data = try! Data(contentsOf: filePath)
            let html = data.withUnsafeBytes { (pointer: UnsafePointer<CChar>) -> String in
                return String(cString: pointer)
            }
            
            guard let doc = HTMLDocument(html: html, encoding: .utf8) else {
                return
            }
            // Check title
            XCTAssert(doc.title == "Test HTML4")
            XCTAssert(doc.head != nil)
            XCTAssert(doc.body != nil)
            XCTAssert(doc.html!.hasPrefix("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\n<html lang=\"en\">"))
            
            for link in doc.search(byXPath: "//link") {
                XCTAssert(link["href"] != nil)
            }
            
            let repoName = ["Kanna", "Swift-HTML-Parser"]
            for (index, repo) in doc.search(byXPath: "//span[@class='repo']").enumerated() {
                XCTAssert(repo["title"] == repoName[index])
                XCTAssert(repo.text == repoName[index])
            }
            

            #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
                if let snTable = doc.atCSSSelector("table[id='sequence number']") {
                    let alphabet = ["a", "b", "c"]
                    for (indexTr, tr) in snTable.search(byCSSSelector: "tr").enumerated() {
                        for (indexTd, td) in tr.search(byCSSSelector: "td").enumerated() {
                            XCTAssert(td.text == "\(alphabet[indexTd])\(indexTr)")
                        }
                    }
                }
                
                if let starTable = doc.atCSSSelector("table[id='star table']"),
                    let allStarStr = starTable.atCSSSelector("tfoot > tr > td:nth-child(2)")?.text,
                    let allStar = Int(allStarStr) {
                    var count = 0
                    
                    for starNode in starTable.search(byCSSSelector: "tbody > tr > td:nth-child(2)") {
                        if let starStr = starNode.text,
                            let star    = Int(starStr) {
                            count += star
                        }
                    }
                    
                    XCTAssert(count == allStar)
                } else {
                    XCTAssert(false, "Star not found.")
                }
                
                if var link = doc.atCSSSelector("//link") {
                    let attr = "src-data"
                    let testData = "TestData"
                    link[attr] = testData
                    XCTAssert(link[attr] == testData)
                }
            #endif
            
            XCTAssertTrue(doc.search(byXPath: "true()").boolValue)
            XCTAssertEqual(doc.search(byXPath: "number(123)").numberValue, 123)
            XCTAssertEqual(doc.search(byXPath: "concat((//a/@href)[1], (//a/@href)[2])").stringValue,
                           "/tid-kijyun/Kanna/tid-kijyun/Swift-HTML-Parser")
        } catch {
            XCTAssert(false, "File not found. name: (\(filename)), error: \(error)")
        }
    }
    

    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    func testInnerHTML() {
        let filename = "test_HTML4.html"
        
        let filePath = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent(filename)
        
        do {
            let html = try String(contentsOf: filePath)
            guard let doc = HTMLDocument(html: html, encoding: .utf8) else {
                return
            }
            
            XCTAssert(doc.atCSSSelector("div#inner")!.innerHTML == "\n        abc<div>def</div>hij<span>klmn</span>opq\n    ")
            XCTAssert(doc.atCSSSelector("#asd")!.innerHTML == "asd")
        } catch {
            XCTAssert(false, "File not found. name: (\(filename)), error: \(error)")
        }
    }
    #endif
    

    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    func testHTML_MovingNode() {
        let html = "<body><div>A love triangle.<h1>Three's Company</h1></div></body>"
        let modifyPrevHTML = "<body>\n<h1>Three's Company</h1>\n<div>A love triangle.</div>\n</body>"
        let modifyNextHTML = "<body>\n<div>A love triangle.</div>\n<h1>Three's Company</h1>\n</body>"
        
        do {
            guard let doc = HTMLDocument(html: html, encoding: .utf8),
                let h1 = doc.atCSSSelector("h1"),
                let div = doc.atCSSSelector("div") else {
                    return
            }
            div.addPreviousSibling(h1)
            XCTAssert(doc.body!.html == modifyPrevHTML)
        }
        
        do {
            guard let doc = HTMLDocument(html: html, encoding: .utf8),
                let h1 = doc.atCSSSelector("h1"),
                let div = doc.atCSSSelector("div") else {
                    return
            }
            div.addNextSibling(h1)
            XCTAssert(doc.body!.html == modifyNextHTML)
        }
    }
    #endif
}
