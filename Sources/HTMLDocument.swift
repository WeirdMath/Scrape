//
//  HTMLDocument.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

import Foundation
import CoreFoundation
import CLibxml2

/// Instances of this class represent HTML documents.
public final class HTMLDocument: HTMLDocumentType {

    internal var documentPointer: xmlDocPtr
    internal var rootNode: XMLElement
    
    /// Creates an `HTMLDocument` instance from a string.
    ///
    /// - parameter html:       A string to create the document from.
    /// - parameter url:        The base URL to use for the document. Default is `nil`.
    /// - parameter encoding:   Encoding to use for parsing HTML.
    /// - parameter options:    Options to use for parsing HTML. Default value is `HTMLParserOptions.default`.
    public init?(html: String,
                 url: String? = nil,
                 encoding: String.Encoding,
                 options: HTMLParserOptions = .default) {

        guard html.lengthOfBytes(using: encoding) > 0 else { return nil }

        let cfEncoding = CFStringConvertNSStringEncodingToEncoding(encoding.rawValue)
        let cfEncodingName = CFStringConvertEncodingToIANACharSetName(cfEncoding)

        guard let htmlCString = html.cString(using: encoding), !htmlCString.isEmpty else { return nil }

        let documentPointer: xmlDocPtr? = htmlCString.withUnsafeBufferPointer {
            return $0.baseAddress!.withMemoryRebound(to: xmlChar.self, capacity: $0.count) {

                let encodingName: String? =
                    cfEncodingName == nil ? nil : String(describing: cfEncodingName!)

                return htmlReadDoc($0, url, encodingName, CInt(options.rawValue))
            }
        }

        if let documentPointer = documentPointer, let rootNode = XMLNode(documentPointer: documentPointer) {
            self.documentPointer = documentPointer
            self.rootNode = rootNode
        } else {
            return nil
        }
    }

    /// Creates an `HTMLDocument` instance from binary data.
    ///
    /// - parameter html:       Data to create the document from.
    /// - parameter url:        The base URL to use for the document. Default is `nil`.
    /// - parameter encoding:   Encoding to use for parsing HTML.
    /// - parameter options:    Options to use for parsing HTML. Default value is `HTMLParserOptions.default`.
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

    /// Creates an `HTMLDocument` instance from binary data.
    ///
    /// - parameter url:        URL to load the document from.
    /// - parameter encoding:   Encoding to use for parsing HTML.
    /// - parameter options:    Options to use for parsing HTML. Default value is `HTMLParserOptions.default`.
    public convenience init?(url: URL, encoding: String.Encoding, options: HTMLParserOptions = .default) {

        #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
            if let data = try? Data(contentsOf: url) {
                self.init(html: data, url: url.path, encoding: encoding, options: options)
            } else {
                return nil
            }
        #else
            // FIXME: `try? Data(contentsOf: url)` causes segmentation fault in Linux
            // (probably https://bugs.swift.org/browse/SR-1547)
            if let nsdata = try? NSData(contentsOfFile: url.path, options: []) {
                let data =  Data(referencing: nsdata)
                self.init(html: data, url: url.path, encoding: encoding, options: options)
            } else {
                return nil
            }
        #endif
    }

    deinit {
        xmlFreeDoc(documentPointer)
    }
}
