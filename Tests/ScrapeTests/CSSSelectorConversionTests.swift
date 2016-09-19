//
//  CSSSelectorConversionTests.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 16.09.16.
//
//

#if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)

import XCTest
import Scrape
import Foundation

final class CSSSelectorConversionTests: XCTestCase {
    
    static let allTests = {
        return [
            ("testGetElements", testGetElements),
            ("testGetClass", testGetClass),
            ("testGetID", testGetID),
            ("testGetElementWithClassAndID", testGetElementWithClassAndID),
            ("testGetTwoClasses", testGetTwoClasses),
            ("testGetTwoElements", testGetTwoElements),
            ("testGetTwoElementsWithClasses", testGetTwoElementsWithClasses),
            ("testGetElementsWithDirectParent", testGetElementsWithDirectParent),
            ("testGetElementsWithPlusCombinator", testGetElementsWithPlusCombinator),
            ("testGetElementsWithAttribute", testGetElementsWithAttribute),
            ("testGetElementsWithAttributeWithValue", testGetElementsWithAttributeWithValue),
            ("testGetElementsWithAttributeWithValueContainingWord",
             testGetElementsWithAttributeWithValueContainingWord),
            ("testGetElementsWithAttributeWithValueStartingWithSubtringFollowedByHyphen",
             testGetElementsWithAttributeWithValueStartingWithSubtringFollowedByHyphen),
            ("testGetElementsWithAttributeWithValueContainingSubstring",
             testGetElementsWithAttributeWithValueContainingSubstring),
            ("testGetElementsWithAttributeWithValueStartingWithSubtring",
             testGetElementsWithAttributeWithValueStartingWithSubtring),
            ("testGetElementsWithAttributeWithValueEndingWithSubtring",
             testGetElementsWithAttributeWithValueEndingWithSubtring),
            ("testGetElementsWithPseudoclassFirstChild", testGetElementsWithPseudoclassFirstChild),
            ("testGetElementsWithPseudoclassLastChild", testGetElementsWithPseudoclassLastChild),
            ("testGetElementsWithPseudoclassOnlyChild", testGetElementsWithPseudoclassOnlyChild),
            ("testGetElementsWithPseudoclassFirstOfType", testGetElementsWithPseudoclassFirstOfType),
            ("testGetElementsWithPseudoclassLastOfType", testGetElementsWithPseudoclassLastOfType),
            ("testGetElementsWithPseudoclassOnlyOfType", testGetElementsWithPseudoclassOnlyOfType),
            ("testGetElementsWithPseudoclassEmpty", testGetElementsWithPseudoclassEmpty),
            ("testGetElementsWithPseudoclassNthChild0", testGetElementsWithPseudoclassNthChild0),
            ("testGetElementsWithPseudoclassNthChild3", testGetElementsWithPseudoclassNthChild3),
            ("testGetElementsWithPseudoclassNthChildOdd", testGetElementsWithPseudoclassNthChildOdd),
            ("testGetElementsWithPseudoclassNthChildEven", testGetElementsWithPseudoclassNthChildEven),
            ("testGetElementsWithPseudoclassNthChild3n", testGetElementsWithPseudoclassNthChild3n),
            ("testGetElementsWithPseudoclassNthLastChild2", testGetElementsWithPseudoclassNthLastChild2),
            ("testGetElementsWithPseudoclassNthOfTypeOdd", testGetElementsWithPseudoclassNthOfTypeOdd),
            ("testGetRoot", testGetRoot),
            ("testGetElementsContainingSubstring", testGetElementsContainingSubstring),
            ("testGetElementsNotWithArgumentWithValue", testGetElementsNotWithArgumentWithValue),
            ("testGetElementsNotOfType", testGetElementsNotOfType),
            ("testGetElementsWithNamespace", testGetElementsWithNamespace),
            ("testGetElementsForComplexQuery1", testGetElementsForComplexQuery1),
            ("testGetElementsForComplexQuery2", testGetElementsForComplexQuery2),
            ("testGetElementsForComplexQuery3", testGetElementsForComplexQuery3),
        ]
    }()
    
    func testGetElements() {
        
        // Given
        let selector = "*, div"
        let expectedXPath = "//* | //div"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetClass() {
        
        // Given
        let selector = ".myclass"
        let expectedXPath = "//*[contains(concat(' ', normalize-space(@class), ' '), ' myclass ')]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetID() {
        
        // Given
        let selector = "#myid"
        let expectedXPath = "//*[@id = 'myid']"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementWithClassAndID() {
        
        // Given
        let selector = "div.myclass#myid"
        let expectedXPath = "//div[contains(concat(' ', normalize-space(@class), ' '), ' myclass ')" +
        " and @id = 'myid']"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetTwoClasses() {
        
        // Given
        let selector = ".myclass.myclass2"
        let expectedXPath = "//*[contains(concat(' ', normalize-space(@class), ' '), ' myclass ')" +
        " and contains(concat(' ', normalize-space(@class), ' '), ' myclass2 ')]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetTwoElements() {
        
        // Given
        let selector = "div span"
        let expectedXPath = "//div//span"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetTwoElementsWithClasses() {
        
        // Given
        let selector = "ul.info li.favo"
        let expectedXPath = "//ul[contains(concat(' ', normalize-space(@class), ' '), ' info ')]//" +
        "li[contains(concat(' ', normalize-space(@class), ' '), ' favo ')]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithDirectParent() {
        
        // Given
        let selector = "div > span"
        let expectedXPath = "//div/span"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithPlusCombinator() {
        
        // Given
        let selector = "div + span"
        let expectedXPath = "//div/following-sibling::*[1]/self::span"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithAttribute() {
        
        // Given
        let selector = "div[attr]"
        let expectedXPath = "//div[@attr]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithAttributeWithValue() {
        
        // Given
        let selector = "div[attr='val']"
        let expectedXPath = "//div[@attr = 'val']"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithAttributeWithValueContainingWord() {
        
        // Given
        let selector = "div[attr~='val']"
        let expectedXPath = "//div[contains(concat(' ', @attr, ' '),concat(' ', 'val', ' '))]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithAttributeWithValueStartingWithSubtringFollowedByHyphen() {
        
        // Given
        let selector = "div[attr|='val']"
        let expectedXPath = "//div[@attr = 'val' or starts-with(@attr,concat('val', '-'))]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithAttributeWithValueContainingSubstring() {
        
        // Given
        let selector = "div[attr*='val']"
        let expectedXPath = "//div[contains(@attr, 'val')]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithAttributeWithValueStartingWithSubtring() {
        
        // Given
        let selector = "div[attr^='val']"
        let expectedXPath = "//div[starts-with(@attr, 'val')]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithAttributeWithValueEndingWithSubtring() {
        
        // Given
        let selector = "div[attr$='val']"
        let expectedXPath = "//div[substring(@attr, string-length(@attr) - string-length('val') + 1," +
        " string-length('val')) = 'val']"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithPseudoclassFirstChild() {
        
        // Given
        let selector = "div:first-child"
        let expectedXPath = "//div[count(preceding-sibling::*) = 0]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithPseudoclassLastChild() {
        
        // Given
        let selector = "div:last-child"
        let expectedXPath = "//div[count(following-sibling::*) = 0]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithPseudoclassOnlyChild() {
        
        // Given
        let selector = "div:only-child"
        let expectedXPath = "//div[count(preceding-sibling::*) = 0 and count(following-sibling::*) = 0]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithPseudoclassFirstOfType() {
        
        // Given
        let selector = "div:first-of-type"
        let expectedXPath = "//div[position() = 1]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithPseudoclassLastOfType() {
        
        // Given
        let selector = "div:last-of-type"
        let expectedXPath = "//div[position() = last()]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithPseudoclassOnlyOfType() {
        
        // Given
        let selector = "div:only-of-type"
        let expectedXPath = "//div[last() = 1]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithPseudoclassEmpty() {
        
        // Given
        let selector = "div:empty"
        let expectedXPath = "//div[not(node())]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithPseudoclassNthChild0() {
        
        // Given
        let selector = "div:nth-child(0)"
        let expectedXPath = "//div[count(preceding-sibling::*) = -1]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithPseudoclassNthChild3() {
        
        // Given
        let selector = "div:nth-child(3)"
        let expectedXPath = "//div[count(preceding-sibling::*) = 2]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithPseudoclassNthChildOdd() {
        
        // Given
        let selector = "div:nth-child(odd)"
        let expectedXPath = "//div[((count(preceding-sibling::*) + 1) >= 1) and" +
        " ((((count(preceding-sibling::*) + 1)-1) mod 2) = 0)]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithPseudoclassNthChildEven() {
        
        // Given
        let selector = "div:nth-child(even)"
        let expectedXPath = "//div[((count(preceding-sibling::*) + 1) mod 2) = 0]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithPseudoclassNthChild3n() {
        
        // Given
        let selector = "div:nth-child(3n)"
        let expectedXPath = "//div[((count(preceding-sibling::*) + 1) mod 3) = 0]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithPseudoclassNthLastChild2() {
        
        // Given
        let selector = "div:nth-last-child(2)"
        let expectedXPath = "//div[count(following-sibling::*) = 1]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithPseudoclassNthOfTypeOdd() {
        
        // Given
        let selector = "div:nth-of-type(odd)"
        let expectedXPath = "//div[(position() >= 1) and (((position()-1) mod 2) = 0)]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetRoot() {
        
        // Given
        let selector = "*:root"
        let expectedXPath = "//*[not(parent::*)]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsContainingSubstring() {
        
        // Given
        let selector = "div:contains('foo')"
        let expectedXPath = "//div[contains(., 'foo')]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsNotWithArgumentWithValue() {
        
        // Given
        let selector = "div:not([type='text'])"
        let expectedXPath = "//div[not(@type = 'text')]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsNotOfType() {
        
        // Given
        let selector = "*:not(div)"
        let expectedXPath = "//*[not(self::div)]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsWithNamespace() {
        
        // Given
        let selector = "o|Author"
        let expectedXPath = "//o:Author"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsForComplexQuery1() {
        
        // Given
        let selector = "#content > p:not(.article-meta)"
        let expectedXPath = "//*[@id = 'content']/p[not(contains(concat(' ', normalize-space(@class), ' ')," +
        " ' article-meta '))]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsForComplexQuery2() {
        
        // Given
        let selector = "div:not(:nth-child(-n+2))"
        let expectedXPath = "//div[not((count(preceding-sibling::*) + 1) <= 2)]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
    
    func testGetElementsForComplexQuery3() {
        
        // Given
        let selector = "*:not(:not(div))"
        let expectedXPath = "//*[not(not(self::div))]"
        
        // When
        let returnedXPath = CSSSelector(selector)?.xpath
        
        // Then
        XCTAssertEqual(expectedXPath, returnedXPath)
    }
}

#endif
