//
//  LinuxMain.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 12.09.16.
//
//

import XCTest
@testable import ScrapeTests

XCTMain([
    testCase(XMLDocumentTests.allTests),
    testCase(HTMLDocumentTests.allTests),
    testCase(XMLNodeTests.allTests),
    testCase(XMLNodeSetTests.allTests)
])
