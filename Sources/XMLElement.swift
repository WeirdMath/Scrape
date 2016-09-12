//
//  XMLElement.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

/// Instances of conforming types can provide a number of means to see and edit an internal structure
/// of XML nodes.
public protocol XMLElement: Node {
    
    /// Parent element of `self` in the DOM.
    ///
    /// In the following example "foo" is a parent for elements "bar" and "baz":
    ///
    /// ```xml
    /// <foo>
    ///   <bar>Hello</bar>
    ///   <baz>World</baz>
    /// </foo>
    /// ```
    ///
    /// If we now set "baz" to be a parent of "bar", then we get the following:
    ///
    /// ```xml
    /// <foo>
    ///   <baz>
    ///     World
    ///     <bar>Hello</bar>
    ///   </baz>
    /// </foo>
    /// ```
    var parent: XMLElement? { get set }
    
    /// Returns a value of a specified `attribute` of `self`.
    ///
    /// In the following example let's assume that `foo` is of type `XMLElement` and
    /// represents the "foo" tag. In this case the value of `foo["class"]` is `"top-header"`.
    ///
    /// ```xml
    /// <foo class="top-header">Hello, World!</foo>
    /// ```
    ///
    /// Attribute value can also be set. If initially there were no attibute with
    /// the specified name, it will be created, otherwise its value will be rewritten.
    /// For example, if we use `foo["class"] = "subheader"`,
    /// then we get the following:
    ///
    /// ```xml
    /// <foo class="subheader">Hello, World!</foo>
    /// ```
    ///
    /// If the value we set is `nil`, the attribute will be removed:
    ///
    /// ```xml
    /// <foo>Hello, World!</foo>
    /// ```
    ///
    /// - complexity: O(n), where n is the number of attributes.
    ///
    /// - parameter attribute: The name of an attribute.
    ///
    /// - returns: A value of a specified `attribute` of `self`, or `nil` if no such attribute exist.
    subscript(attribute: String) -> String? { get set }
    
    /// Adds a new `node` as the previous sibling of `self`. If the new node was already inserted
    /// in a document, it is first unlinked from its existing context.
    ///
    /// Suppose we have the following:
    ///
    /// ```xml
    /// <foo>
    ///   <baz>
    ///     World
    ///     <bar>Hello</bar>
    ///   </baz>
    /// </foo>
    /// ```
    ///
    /// Let `self` represents the tag "baz" and `bar` represents the tag "bar".
    /// After calling `addPreviousSibling(bar)` on `self`, here will be the result:
    ///
    /// ```xml
    /// <foo>
    ///   <bar>Hello</bar>
    ///   <baz>World</baz>
    /// </foo>
    /// ```
    ///
    /// - parameter node: A node to add as a previous sibling of `self`.
    func addPreviousSibling(_ node: XMLElement)
    
    /// Adds a new `node` as the next sibling of `self`. If the new node was already inserted
    /// in a document, it is first unlinked from its existing context.
    ///
    /// Suppose we have the following:
    ///
    /// ```xml
    /// <foo>
    ///   <baz>
    ///     Hello
    ///     <bar>World</bar>
    ///   </baz>
    /// </foo>
    /// ```
    ///
    /// Let `self` represents the tag "baz" and `bar` represents the tag "bar".
    /// After calling `addNextSibling(bar)` on `self`, here will be the result:
    ///
    /// ```xml
    /// <foo>
    ///   <baz>Hello</baz>
    ///   <bar>World</bar>
    /// </foo>
    /// ```
    ///
    /// - parameter node: A node to add as a next sibling of `self`.
    func addNextSibling(_ node: XMLElement)
    
    /// Removes a child node of `self`.
    ///
    /// In the example below let "foo" tag is representet by `self`, whereas "bar" tag is represented
    /// by `bar`.
    ///
    /// ```xml
    /// <foo>
    ///   Hello
    ///   <bar>World</bar>
    /// </foo>
    /// ```
    ///
    /// Calling `removeChild(bar)` results in the following:
    /// ```xml
    /// <foo>
    ///   Hello
    /// </foo>
    /// ```
    ///
    /// - parameter node: A node to remove. `self` must be the parent of the `node.`
    func removeChild(_ node: XMLElement)
}
