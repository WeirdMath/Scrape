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

extension HTMLDocumentType {
    
    public final var title: String? {
        return head?.atXPath("title")?.text
    }
    
    public final var head: XMLElement? {
        return atXPath("//head")
    }
    
    public final var body: XMLElement? {
        return atXPath("//body")
    }
}
