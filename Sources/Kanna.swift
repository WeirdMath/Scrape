/**@file Kanna.swift

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

/// Parse XML
///
/// - parameter xml:      an XML string
/// - parameter url:      the base URL to use for the document
/// - parameter encoding: the document encoding
/// - parameter option:   a ParserOption
public func XML(xml: String, url: String?, encoding: String.Encoding, option: ParseOption = .defaultXML) -> XMLDocument? {
    switch option {
    case .xml(let opt):
        return LibxmlXMLDocument(xml: xml, url: url, encoding: encoding, options: opt)
    default:
        return nil
    }
}

public func XML(xml: String, encoding: String.Encoding, option: ParseOption = .defaultXML) -> XMLDocument? {
    return XML(xml: xml, url: nil, encoding: encoding, option: option)
}

public func XML(xml: Data, url: String?, encoding: String.Encoding, option: ParseOption = .defaultXML) -> XMLDocument? {
    if let xmlStr = NSString(data: xml, encoding: encoding.rawValue) as? String {
        return XML(xml: xmlStr, url: url, encoding: encoding, option: option)
    }
    return nil
}

public func XML(xml: Data, encoding: String.Encoding, option: ParseOption = .defaultXML) -> XMLDocument? {
    return XML(xml: xml, url: nil, encoding: encoding, option: option)
}

public func XML(url: URL, encoding: String.Encoding, option: ParseOption = .defaultXML) -> XMLDocument? {
    if let data = try? Data(contentsOf: url) {
        return XML(xml: data, url: url.absoluteString, encoding: encoding, option: option)
    }
    return nil
}

/// Parse HTML
///
/// - parameter html:     an HTML string
/// - parameter url:      the base URL to use for the document
/// - parameter encoding: the document encoding
/// - parameter option:   a ParserOption
public func HTML(html: String, url: String?, encoding: UInt, option: ParseOption = .defaultHTML) -> HTMLDocument? {
    switch option {
    case .html(let opt):
        return LibxmlHTMLDocument(html: html, url: url, encoding: encoding, option: opt.rawValue)
    default:
        return nil
    }
}

public func HTML(html: String, encoding: UInt, option: ParseOption = .defaultHTML) -> HTMLDocument? {
    return HTML(html: html, url: nil, encoding: encoding, option: option)
}

public func HTML(html: Data, url: String?, encoding: UInt, option: ParseOption = .defaultHTML) -> HTMLDocument? {
    if let htmlStr = NSString(data: html, encoding: encoding) as? String {
        return HTML(html: htmlStr, url: url, encoding: encoding, option: option)
    }
    return nil
}

public func HTML(html: Data, encoding: UInt, option: ParseOption = .defaultHTML) -> HTMLDocument? {
    return HTML(html: html, url: nil, encoding: encoding, option: option)
}

public func HTML(url: URL, encoding: UInt, option: ParseOption = .defaultHTML) -> HTMLDocument? {
    if let data = try? Data(contentsOf: url) {
        return HTML(html: data, url: url.absoluteString, encoding: encoding, option: option)
    }
    return nil
}
