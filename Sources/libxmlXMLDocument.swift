//
//  libxmlXMLDocument.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

import Foundation
import CLibxml2

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
    
    func search(byXPath xpath: String, namespaces: [String : String]?) -> XPath {
        return rootNode?.search(byXPath: xpath, namespaces: namespaces) ?? .none
    }
    
    func search(byCSSSelector selector: String, namespaces: [String : String]?) -> XPath {
        return rootNode?.search(byCSSSelector: selector, namespaces: namespaces) ?? .none
    }
}

