/**@file libxmlHTMLDocument.swift

Kanna

Copyright (c) 2015 Atsushi Kiwaki (@_tid_)

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

import Foundation
import CLibxml2

internal final class libxmlHTMLDocument: HTMLDocument {
    private var docPtr: htmlDocPtr? = nil
    private var rootNode: XMLElement?
    private var html: String
    private var url:  String?
    private var encoding: UInt
    
    var text: String? {
        return rootNode?.text
    }

    var toHTML: String? {
        let buf = xmlBufferCreate()
        defer {
            xmlBufferFree(buf)
        }

        let outputBuf = xmlOutputBufferCreateBuffer(buf, nil)
        htmlDocContentDumpOutput(outputBuf, docPtr, nil)
        let html = String.decodeCString(xmlOutputBufferGetContent(outputBuf), as: UTF8.self)?.result
        return html
    }

    var toXML: String? {
        var buf: UnsafeMutablePointer<xmlChar>? = nil
        let size: UnsafeMutablePointer<Int32>? = nil
        defer {
            xmlFree(buf)
        }

        xmlDocDumpMemory(docPtr, &buf, size)
        let html = String.decodeCString(buf, as: UTF8.self)?.result
        return html
    }
    
    var innerHTML: String? {
        return rootNode?.innerHTML
    }
    
    var className: String? {
        return nil
    }
    
    var tagName:   String? {
        get {
            return nil
        }

        set {

        }
    }

    var content: String? {
        get {
            return text
        }

        set {
            rootNode?.content = newValue
        }
    }
    
    init?(html: String, url: String?, encoding: UInt, option: UInt) {
        self.html = html
        self.url  = url
        self.encoding = encoding
        
        if html.lengthOfBytes(using: String.Encoding(rawValue: encoding)) <= 0 {
            return nil
        }
        let cfenc : CFStringEncoding = CFStringConvertNSStringEncodingToEncoding(encoding)
        let cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc)
        
        if let cur = html.cString(using: String.Encoding(rawValue: encoding)) {
            let url : String = ""
            docPtr = cur.withUnsafeBufferPointer {
                cur in
                return cur.baseAddress?.withMemoryRebound(to: xmlChar.self, capacity: cur.count) {
                    cur in
                    return htmlReadDoc(cur, url, String(describing: cfencstr), CInt(option))
                }
            }
            rootNode  = libxmlHTMLNode(docPtr: docPtr)
        } else {
            return nil
        }
    }
    
    deinit {
        xmlFreeDoc(self.docPtr)
    }

    var title: String? { return at_xpath("//title")?.text }
    var head: XMLElement? { return at_xpath("//head") }
    var body: XMLElement? { return at_xpath("//body") }
    
    func xpath(_ xpath: String, namespaces: [String:String]?) -> XPathObject {
        return rootNode?.xpath(xpath, namespaces: namespaces) ?? XPathObject.none
    }
    
    func xpath(_ xpath: String) -> XPathObject {
        return self.xpath(xpath, namespaces: nil)
    }
    
    func at_xpath(_ xpath: String, namespaces: [String:String]?) -> XMLElement? {
        return rootNode?.at_xpath(xpath, namespaces: namespaces)
    }
    
    func at_xpath(_ xpath: String) -> XMLElement? {
        return self.at_xpath(xpath, namespaces: nil)
    }
    
    func css(_ selector: String, namespaces: [String:String]?) -> XPathObject {
        return rootNode?.css(selector, namespaces: namespaces) ?? XPathObject.none
    }
    
    func css(_ selector: String) -> XPathObject {
        return self.css(selector, namespaces: nil)
    }
    
    func at_css(_ selector: String, namespaces: [String:String]?) -> XMLElement? {
        return rootNode?.at_css(selector, namespaces: namespaces)
    }
    
    func at_css(_ selector: String) -> XMLElement? {
        return self.at_css(selector, namespaces: nil)
    }
}

internal final class libxmlXMLDocument: XMLDocument {
    private var docPtr: xmlDocPtr?
    private var rootNode: XMLElement?
    private var xml: String
    private var url: String?
    private var encoding: UInt
    
    var text: String? {
        return rootNode?.text
    }
    
    var toHTML: String? {
        let buf = xmlBufferCreate()
        defer {
            xmlBufferFree(buf)
        }

        let outputBuf = xmlOutputBufferCreateBuffer(buf, nil)
        htmlDocContentDumpOutput(outputBuf, docPtr, nil)
        let html = String.decodeCString(xmlOutputBufferGetContent(outputBuf), as: UTF8.self)?.result
        return html
    }

    var toXML: String? {
        var buf: UnsafeMutablePointer<xmlChar>?
        let size: UnsafeMutablePointer<Int32>? = nil
        defer {
            xmlFree(buf)
        }

        xmlDocDumpMemory(docPtr, &buf, size)
        
        return String.decodeCString(buf, as: UTF8.self)?.result
    }
    
    var innerHTML: String? {
        return rootNode?.innerHTML
    }
    
    var className: String? {
        return nil
    }
    
    var tagName:   String? {
        get {
            return nil
        }

        set {
            
        }
    }

    var content: String? {
        get {
            return text
        }

        set {
            rootNode?.content = newValue
        }
    }
    
    init?(xml: String, url: String?, encoding: UInt, option: UInt) {
        self.xml  = xml
        self.url  = url
        self.encoding = encoding
        
        if xml.lengthOfBytes(using: String.Encoding(rawValue: encoding)) <= 0 {
            return nil
        }
        let cfenc : CFStringEncoding = CFStringConvertNSStringEncodingToEncoding(encoding)
        let cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc)!
        
        if let cur = xml.cString(using: String.Encoding(rawValue: encoding)) {
            let url : String = ""
            docPtr = cur.withUnsafeBufferPointer { cur in
                return cur.baseAddress?.withMemoryRebound(to: xmlChar.self, capacity: cur.count) { cur in
                    return xmlReadDoc(cur, url, String(describing: cfencstr), CInt(option))
                }
            }
            rootNode  = libxmlHTMLNode(docPtr: docPtr)
        } else {
            return nil
        }
    }

    deinit {
        xmlFreeDoc(self.docPtr)
    }
    
    func xpath(_ xpath: String, namespaces: [String:String]?) -> XPathObject {
        return rootNode?.xpath(xpath, namespaces: namespaces) ?? XPathObject.none
    }
    
    func xpath(_ xpath: String) -> XPathObject {
        return self.xpath(xpath, namespaces: nil)
    }
    
    func at_xpath(_ xpath: String, namespaces: [String:String]?) -> XMLElement? {
        return rootNode?.at_xpath(xpath, namespaces: namespaces)
    }
    
    func at_xpath(_ xpath: String) -> XMLElement? {
        return self.at_xpath(xpath, namespaces: nil)
    }
    
    func css(_ selector: String, namespaces: [String:String]?) -> XPathObject {
        return rootNode?.css(selector, namespaces: namespaces) ?? XPathObject.none
    }
    
    func css(_ selector: String) -> XPathObject {
        return self.css(selector, namespaces: nil)
    }
    
    func at_css(_ selector: String, namespaces: [String:String]?) -> XMLElement? {
        return rootNode?.at_css(selector, namespaces: namespaces)
    }
    
    func at_css(_ selector: String) -> XMLElement? {
        return self.at_css(selector, namespaces: nil)
    }
}
