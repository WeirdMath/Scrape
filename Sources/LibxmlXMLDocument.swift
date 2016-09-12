//
//  LibxmlXMLDocument.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

import Foundation
import CLibxml2

internal final class LibxmlXMLDocument: XMLDocument {
    
    private var documentPointer: xmlDocPtr
    private var rootNode: XMLElement?
    private var _xml: String
    private var url: String?
    private var encoding: String.Encoding
    
    init?(xml: String, url: String? = nil, encoding: String.Encoding, options: XMLParserOptions) {
        _xml  = xml
        self.url  = url
        self.encoding = encoding
        
        if xml.lengthOfBytes(using: encoding) <= 0 {
            return nil
        }
        
        // TODO: Remove this check when Foundation has this functions on Linux
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            let cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)
            let cfEncodingString = CFStringConvertEncodingToIANACharSetName(cfEncoding)
        #endif
        
        
        guard let xmlCString = xml.cString(using: encoding), !xmlCString.isEmpty else {
            return nil
        }
        
        documentPointer = xmlCString.withUnsafeBufferPointer {
            return $0.baseAddress!.withMemoryRebound(to: xmlChar.self, capacity: $0.count) {
                
                #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
                    
                    let encodingName: String? =
                        cfEncodingString == nil ? nil : String(describing: cfEncodingString!)
                    
                    return xmlReadDoc($0, url, encodingName, CInt(options.rawValue))
                #else
                    
                    return xmlReadDoc($0, url, encoding.ianaName, CInt(options.rawValue))
                #endif
            }
        }
        
        rootNode = LibxmlHTMLNode(documentPointer: documentPointer)
    }
    
    deinit {
        xmlFreeDoc(documentPointer)
    }
    
    var text: String? {
        return rootNode?.text
    }
    
    var html: String? {
        let buf = xmlBufferCreate()
        defer {
            xmlBufferFree(buf)
        }
        
        let outputBuf = xmlOutputBufferCreateBuffer(buf, nil)
        htmlDocContentDumpOutput(outputBuf, documentPointer, nil)
        let html = String.decodeCString(xmlOutputBufferGetContent(outputBuf), as: UTF8.self)?.result
        return html
    }
    
    var xml: String? {
        var buf: UnsafeMutablePointer<xmlChar>?
        let size: UnsafeMutablePointer<Int32>? = nil
        defer {
            xmlFree(buf)
        }
        
        xmlDocDumpMemory(documentPointer, &buf, size)
        
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
    
    func search(byXPath xpath: String, namespaces: [String : String]?) -> XPath {
        return rootNode?.search(byXPath: xpath, namespaces: namespaces) ?? .none
    }
    
    func search(byCSSSelector selector: String, namespaces: [String : String]?) -> XPath {
        return rootNode?.search(byCSSSelector: selector, namespaces: namespaces) ?? .none
    }
}

