//
//  HTMLDocument.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

import Foundation
import CLibxml2

public final class HTMLDocument: HTMLDocumentType {
    
    var documentPointer: htmlDocPtr
    var rootNode: XMLElement
    private var _html: String
    private var _url:  String?
    private var _encoding: String.Encoding
    
    public init?(html: String,
                 url: String? = nil,
                 encoding: String.Encoding,
                 options: HTMLParserOptions = .default) {
        
        _html = html
        _url  = url
        _encoding = encoding
        
        guard html.lengthOfBytes(using: encoding) > 0 else { return nil }
        
        // TODO: Remove this check when Foundation has these functions on Linux
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            let cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)
            let cfEncodingName = CFStringConvertEncodingToIANACharSetName(cfEncoding)
        #endif
        
        guard let htmlCString = html.cString(using: encoding), !htmlCString.isEmpty else { return nil }
        
        let documentPointer: xmlDocPtr? = htmlCString.withUnsafeBufferPointer {
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
        
        if let documentPointer = documentPointer, let rootNode = XMLNode(documentPointer: documentPointer) {
            self.documentPointer = documentPointer
            self.rootNode = rootNode
        } else {
            return nil
        }
    }
    
    public convenience init?(html: Data,
                             url: String? = nil,
                             encoding: String.Encoding,
                             options: HTMLParserOptions = .default) {
        
        if let htmlString = String(data: html, encoding: encoding) {
            self.init(html: htmlString, url: url, encoding: encoding, options: options)
        } else {
            return nil
        }
    }
    
    public convenience init?(url: URL, encoding: String.Encoding, options: HTMLParserOptions = .default) {
        
        if let data = try? Data(contentsOf: url) {
            self.init(html: data, url: url.absoluteString, encoding: encoding, options: options)
        } else {
            return nil
        }
    }
    
    deinit {
        xmlFreeDoc(documentPointer)
    }
}
