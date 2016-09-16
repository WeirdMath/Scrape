//
//  XMLDocument.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

import Foundation
import CLibxml2

public final class XMLDocument: XMLDocumentType {
    
    var documentPointer: xmlDocPtr
    var rootNode: XMLElement
    
    private var _xml: String
    private var _url: String?
    private var _encoding: String.Encoding
    
    public init?(xml: String,
                 url: String? = nil,
                 encoding: String.Encoding,
                 options: XMLParserOptions = .default) {
        
        _xml  = xml
        _url  = url
        _encoding = encoding
        
        guard xml.lengthOfBytes(using: encoding) > 0 else { return nil }
        
        // TODO: Remove this check when Foundation has these functions on Linux
        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            let cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)
            let cfEncodingName = CFStringConvertEncodingToIANACharSetName(cfEncoding)
        #endif
        
        
        guard let xmlCString = xml.cString(using: encoding), !xmlCString.isEmpty else { return nil }
        
        let documentPointer: xmlDocPtr? = xmlCString.withUnsafeBufferPointer {
            return $0.baseAddress!.withMemoryRebound(to: xmlChar.self, capacity: $0.count) {
                
                #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
                    
                    let encodingName: String? =
                        cfEncodingName == nil ? nil : String(describing: cfEncodingName!)
                    
                    return xmlReadDoc($0, url, encodingName, CInt(options.rawValue))
                #else
                    return xmlReadDoc($0, url, encoding.ianaName, CInt(options.rawValue))
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
    
    public convenience init?(xml: Data,
                             url: String? = nil,
                             encoding: String.Encoding,
                             options: XMLParserOptions = .default) {
        
        if let xmlString = String(data: xml, encoding: encoding) {
            self.init(xml: xmlString, url: url, encoding: encoding, options: options)
        } else {
            return nil
        }
    }
    
    public convenience init?(url: URL, encoding: String.Encoding, options: XMLParserOptions = .default) {
        
        if let data = try? Data(contentsOf: url) {
            self.init(xml: data, url: url.absoluteString, encoding: encoding, options: options)
        } else {
            return nil
        }
    }
    
    deinit {
        xmlFreeDoc(documentPointer)
    }
}

