//
//  HTMLDocumentType.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

/// Instances of conforming types represent HTML documents that can be asked to provide
/// their `title`, `head` or `body`.
internal protocol HTMLDocumentType: XMLDocumentType {
    var title: String? { get }
    var head: XMLElement? { get }
    var body: XMLElement? { get }
}

/// Instances of conforming types represent HTML documents that can be asked to provide
/// their `title`, `head` or `body`.
extension HTMLDocumentType {
    
    /// The contents of the tag `title` in the document. `nil` if no such tag exist.
    public final var title: String? {
        return head?.element(atXPath: "title")?.text
    }
    
    /// The node representing the tag `head`. `nil` if no such tag exist.
    public final var head: XMLElement? {
        return element(atXPath: "//head")
    }
    
    /// The node representing the tag `body`. `nil` if no such tag exist.
    public final var body: XMLElement? {
        return element(atXPath: "//body")
    }
}
