//
//  HTMLDocument.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

public protocol HTMLDocument: XMLDocument {
    var title: String? { get }
    var head: XMLElement? { get }
    var body: XMLElement? { get }
}
