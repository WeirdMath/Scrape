//
//  SearchableNode.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

public protocol SearchableNode: Searchable {
    var text: String? { get }
    var toHTML: String? { get }
    var toXML: String? { get }
    var innerHTML: String? { get }
    var className: String? { get }
    var tagName: String? { get set }
    var content: String? { get set }
}
