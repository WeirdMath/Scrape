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
    
    var documentPointer: htmlDocPtr
    var rootNode: XMLElement?
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
    
    // MARK: - HTMLDocument
    
    var title: String? {
        return atXPath("//title")?.text
    }
    
    var head: XMLElement? {
        return atXPath("//head")
    }
    
    var body: XMLElement? {
        return atXPath("//body")
    }
}
