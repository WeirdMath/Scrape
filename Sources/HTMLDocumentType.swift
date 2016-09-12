//
//  HTMLDocumentType.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

internal protocol HTMLDocumentType: XMLDocumentType {
    var title: String? { get }
    var head: XMLElement? { get }
    var body: XMLElement? { get }
}
