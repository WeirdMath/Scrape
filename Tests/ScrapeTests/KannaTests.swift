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
@testable import Scrape


class KannaTests: XCTestCase {
    let css2xpath: [(css: String, xpath: String?)] = [
        ("*, div", "//* | //div"),
        (".myclass", "//*[contains(concat(' ', normalize-space(@class), ' '), ' myclass ')]"),
        ("#myid", "//*[@id = 'myid']"),
        ("div.myclass#myid", "//div[contains(concat(' ', normalize-space(@class), ' '), ' myclass ') and @id = 'myid']"),
        (".myclass.myclass2", "//*[contains(concat(' ', normalize-space(@class), ' '), ' myclass ') and contains(concat(' ', normalize-space(@class), ' '), ' myclass2 ')]"),
        ("div span", "//div//span"),
        ("ul.info li.favo", "//ul[contains(concat(' ', normalize-space(@class), ' '), ' info ')]//li[contains(concat(' ', normalize-space(@class), ' '), ' favo ')]"),
        ("div > span", "//div/span"),
        ("div + span", "//div/following-sibling::*[1]/self::span"),
        ("div[attr]", "//div[@attr]"),
        ("div[attr='val']", "//div[@attr = 'val']"),
        ("div[attr~='val']", "//div[contains(concat(' ', @attr, ' '),concat(' ', 'val', ' '))]"),
        ("div[attr|='val']", "//div[@attr = 'val' or starts-with(@attr,concat('val', '-'))]"),
        ("div[attr*='val']", "//div[contains(@attr, 'val')]"),
        ("div[attr^='val']", "//div[starts-with(@attr, 'val')]"),
        ("div[attr$='val']", "//div[substring(@attr, string-length(@attr) - string-length('val') + 1, string-length('val')) = 'val']"),
        ("div:first-child", "//div[count(preceding-sibling::*) = 0]"),
        ("div:last-child", "//div[count(following-sibling::*) = 0]"),
        ("div:only-child", "//div[count(preceding-sibling::*) = 0 and count(following-sibling::*) = 0]"),
        ("div:first-of-type", "//div[position() = 1]"),
        ("div:last-of-type", "//div[position() = last()]"),
        ("div:only-of-type", "//div[last() = 1]"),
        ("div:empty", "//div[not(node())]"),
        ("div:nth-child(0)", "//div[count(preceding-sibling::*) = -1]"),
        ("div:nth-child(3)", "//div[count(preceding-sibling::*) = 2]"),
        ("div:nth-child(odd)", "//div[((count(preceding-sibling::*) + 1) >= 1) and ((((count(preceding-sibling::*) + 1)-1) mod 2) = 0)]"),
        ("div:nth-child(even)", "//div[((count(preceding-sibling::*) + 1) mod 2) = 0]"),
        ("div:nth-child(3n)", "//div[((count(preceding-sibling::*) + 1) mod 3) = 0]"),
        ("div:nth-last-child(2)", "//div[count(following-sibling::*) = 1]"),
        ("div:nth-of-type(odd)", "//div[(position() >= 1) and (((position()-1) mod 2) = 0)]"),
        ("*:root", "//*[not(parent::*)]"),
        ("div:contains('foo')", "//div[contains(., 'foo')]"),
        ("div:not([type='text'])", "//div[not(@type = 'text')]"),
        ("*:not(div)", "//*[not(self::div)]"),
        ("#content > p:not(.article-meta)", "//*[@id = 'content']/p[not(contains(concat(' ', normalize-space(@class), ' '), ' article-meta '))]"),
        ("div:not(:nth-child(-n+2))", "//div[not((count(preceding-sibling::*) + 1) <= 2)]"),
        ("*:not(:not(div))", "//*[not(not(self::div))]"),
        ("o|Author", "//o:Author")
    ]
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    /**
     test CSS to XPath
     */
    func testCSStoXPath() {
        for testCase in css2xpath {
            let xpath = CSS.toXPath(testCase.css)
            XCTAssert(xpath == testCase.xpath, "Create XPath = [\(xpath)] != [\(testCase.xpath)]")
        }
    }
    
    /**
     test XML
     */
    func testXml() {
        let filename = "test_XML_ExcelWorkbook.xml"
        let path = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent(filename)
        if let xml = try? Data(contentsOf: path),
            let doc = XML(xml: xml, encoding: String.Encoding.utf8) {
            let namespaces = [
                "o":  "urn:schemas-microsoft-com:office:office",
                "ss": "urn:schemas-microsoft-com:office:spreadsheet"
            ]
            
            if let author = doc.atXPath("//o:Author", namespaces: namespaces) {
                XCTAssert(author.text == "_tid_")
            } else {
                XCTAssert(false, "Author not found.")
            }
            
            if let createDate = doc.atXPath("//o:Created", namespaces: namespaces) {
                XCTAssert(createDate.text == "2015-07-26T06:00:00Z")
            } else {
                XCTAssert(false, "Create date not found.")
            }
            
            for row in doc.search(byXPath: "//ss:Row", namespaces: namespaces) {
                for cell in row.search(byXPath: "//ss:Data", namespaces: namespaces) {
                    print(cell.text)
                }
            }
        } else {
            XCTAssert(false, "File not found. name: (\(filename))")
        }
    }
    
    func testXML_MovingNode() {
        let xml = "<?xml version=\"1.0\"?><all_item><item><title>item0</title></item><item><title>item1</title></item></all_item>"
        let modifyPrevXML = "<all_item><item><title>item1</title></item><item><title>item0</title></item></all_item>"
        let modifyNextXML = "<all_item><item><title>item1</title></item><item><title>item0</title></item></all_item>"
        
        do {
            guard let doc = XML(xml: xml, encoding: String.Encoding.utf8) else {
                return
            }
            let item0 = doc.search(byCSSSelector: "item")[0]
            let item1 = doc.search(byCSSSelector: "item")[1]
            item0.addPreviousSibling(item1)
            XCTAssert(doc.atCSSSelector("all_item")!.xml == modifyPrevXML)
        }
        
        do {
            guard let doc = XML(xml: xml, encoding: String.Encoding.utf8) else {
                return
            }
            let item0 = doc.search(byCSSSelector: "item")[0]
            let item1 = doc.search(byCSSSelector: "item")[1]
            item1.addNextSibling(item0)
            XCTAssert(doc.atCSSSelector("all_item")!.xml == modifyNextXML)
        }
    }
    
    /**
     test HTML4
     */
    func testHTML4() {
        // This is an example of a functional test case.
        let filename = "test_HTML4"
        guard let path = Bundle(for:self.classForCoder).path(forResource: filename, ofType:"html") else {
            return
        }
        
        do {
            let html = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            guard let doc = HTML(html: html, encoding: String.Encoding.utf8.rawValue) else {
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
            
            if let snTable = doc.atCSSSelector("table[id='sequence number']") {
                let alphabet = ["a", "b", "c"]
                for (indexTr, tr) in snTable.search(byCSSSelector: "tr").enumerated() {
                    for (indexTd, td) in tr.search(byCSSSelector: "tr").enumerated() {
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
            
            XCTAssertTrue(doc.search(byXPath: "true()").boolValue)
            XCTAssertEqual(doc.search(byXPath: "number(123)").numberValue, 123)
            XCTAssertEqual(doc.search(byXPath: "concat((//a/@href)[1], (//a/@href)[2])").stringValue,
                           "/tid-kijyun/Kanna/tid-kijyun/Swift-HTML-Parser")
        } catch {
            XCTAssert(false, "File not found. name: (\(filename)), error: \(error)")
        }
    }
    
    func testInnerHTML() {
        let filename = "test_HTML4"
        guard let path = Bundle(for:self.classForCoder).path(forResource: filename, ofType:"html") else {
            return
        }
        
        do {
            let html = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
            guard let doc = HTML(html: html, encoding: String.Encoding.utf8.rawValue) else {
                return
            }
            
            XCTAssert(doc.atCSSSelector("div#inner")!.innerHTML == "\n        abc<div>def</div>hij<span>klmn</span>opq\n    ")
            XCTAssert(doc.atCSSSelector("#asd")!.innerHTML == "asd")
        } catch {
            XCTAssert(false, "File not found. name: (\(filename)), error: \(error)")
        }
    }
    
    func testNSURL() {
        guard let url = URL(string: "https://en.wikipedia.org/wiki/Cat"),
            let _ = HTML(url: url, encoding: String.Encoding.utf8.rawValue) else {
                XCTAssert(false)
                return
        }
    }
    
    func testHTML_MovingNode() {
        let html = "<body><div>A love triangle.<h1>Three's Company</h1></div></body>"
        let modifyPrevHTML = "<body>\n<h1>Three's Company</h1>\n<div>A love triangle.</div>\n</body>"
        let modifyNextHTML = "<body>\n<div>A love triangle.</div>\n<h1>Three's Company</h1>\n</body>"
        
        do {
            guard let doc = HTML(html: html, encoding: String.Encoding.utf8.rawValue),
                let h1 = doc.atCSSSelector("h1"),
                let div = doc.atCSSSelector("div") else {
                    return
            }
            div.addPreviousSibling(h1)
            XCTAssert(doc.body!.html == modifyPrevHTML)
        }
        
        do {
            guard let doc = HTML(html: html, encoding: String.Encoding.utf8.rawValue),
                let h1 = doc.atCSSSelector("h1"),
                let div = doc.atCSSSelector("div") else {
                    return
            }
            div.addNextSibling(h1)
            XCTAssert(doc.body!.html == modifyNextHTML)
        }
    }
}
