//
//  LibxmlHTMLDocument.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

import Foundation
import CLibxml2

internal final class LibxmlHTMLDocument: HTMLDocument {
    
    private var documentPointer: htmlDocPtr
    private var rootNode: XMLElement?
    private var _html: String
    private var url:  String?
    private var encoding: String.Encoding
    
    init?(html: String, url: String? = nil, encoding: String.Encoding, options: HTMLParserOptions) {
        _html = html
        self.url  = url
        self.encoding = encoding
        
        guard html.lengthOfBytes(using: encoding) > 0 else { return nil }
        
        // TODO: Remove this check when Foundation has these functions on Linux
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            let cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)
            let cfEncodingName = CFStringConvertEncodingToIANACharSetName(cfEncoding)
        #endif
        
        guard let htmlCString = html.cString(using: encoding), !htmlCString.isEmpty else { return nil }
        
        documentPointer = htmlCString.withUnsafeBufferPointer {
            return $0.baseAddress!.withMemoryRebound(to: xmlChar.self, capacity: $0.count) {
                
                #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
                    let encodingName: String? =
                        cfEncodingName == nil ? nil : String(describing: cfEncodingName!)
                    
                    return htmlReadDoc($0, url, encodingName, CInt(options.rawValue))
                #else
                    return htmlReadDoc($0, url, encoding.ianaName, CInt(options.rawValue))
                #endif
            }
        }

        rootNode = LibxmlHTMLNode(documentPointer: documentPointer)
    }
    
    deinit {
        xmlFreeDoc(self.documentPointer)
    }
    
    // MARK: - SearchableNode
    
    var text: String? {
        return rootNode?.text
    }
    
    var html: String? {
        
        let outputBuffer = xmlAllocOutputBuffer(nil)
        defer {
            xmlOutputBufferClose(outputBuffer)
        }
        
        htmlDocContentDumpOutput(outputBuffer, documentPointer, nil)
        
        return String.decodeCString(xmlOutputBufferGetContent(outputBuffer), as: UTF8.self)?.result
    }
    
    var xml: String? {
        
        var buffer: UnsafeMutablePointer<xmlChar>?
        let size: UnsafeMutablePointer<Int32>? = nil
        defer {
            xmlFree(buffer)
            size?.deinitialize()
            size?.deallocate(capacity: 1)
        }
        
        xmlDocDumpMemory(documentPointer, &buffer, size)
        
        return String.decodeCString(buffer, as: UTF8.self)?.result
    }
    
    var innerHTML: String? {
        return rootNode?.className
    }
    
    var className: String? {
        return nil
    }
    
    var tagName:   String? {
        get {
            return rootNode?.tagName
        }
        set {
            rootNode?.tagName = newValue
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
    
    // MARK: - HTMLDocument
    
    var title: String? { return atXPath("//title")?.text }
    var head: XMLElement? { return atXPath("//head") }
    var body: XMLElement? { return atXPath("//body") }
    
    // MARK: Searchable
    
    func search(byXPath xpath: String, namespaces: [String : String]?) -> XPathResult {
        return rootNode?.search(byXPath: xpath, namespaces: namespaces) ?? .none
    }
    
    func search(byCSSSelector selector: String, namespaces: [String : String]?) -> XPathResult {
        return rootNode?.search(byCSSSelector: selector, namespaces: namespaces) ?? .none
    }
}
