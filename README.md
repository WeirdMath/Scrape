# Scrape
![Build Status](https://travis-ci.org/SJTBA/Scrape.svg?branch=master)
![Language](https://img.shields.io/badge/Swift-3.0-orange.svg)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20iOS%20%7C%20watchOS%20%7C%20tvOS-lightgrey.svg)
![codecov](https://codecov.io/gh/SJTBA/Scrape/branch/master/graph/badge.svg)
![codebeat badge](https://codebeat.co/badges/b4f7ff5c-02e4-40cc-bc48-cd515ff613bd)

Scrape is a cross-platform HTML and XML parser written in Swift.

This project was forked from [Kanna](https://github.com/tid-kijyun/Kanna), then completely rewritten and refined.

## About

This framework wraps well-known C library Libxml2, letting you use Swifty interface for HTML and XML parsing. You can use XPath queries or CSS selectors to search elements in XML and HTML documents.

**Important:**
due to immaturity of open source Foundation framework implementation which is used in Linux version
of Scrape, CSS selectors are not currently supported in Linux. When all the methods of `NSRegularExpression` are fully implemented, CSS selectors will come back. In macOS they work just fine.

## Requirements

* macOS 10.9 or newer
* iOS 8.0 or newer
* watchOS 2.0 or newer
* tvOS 9.0 or newer
* Ubuntu 14.04, 15.10 or 16.10
* Other Linux distributions haven't been tested, but everything should work fine.


## Installation
For now only Swift Package Manager is supported. If you want CocoaPods or Carthage support, please feel free
to submit a PR 😊

In order to use Scrape in your SPM project add the following into your `Package.swift` file:

```swift
let package = Package(
    name: "YourPackageName",
    dependencies: [
        .Package(url: "https://github.com/SJTBA/Scrape.git", majorVersion: 1)
    ]
)	
```


## Usage

Consider the following HTML fragment:

```html
    <div class="single-column">
      <ul class="boxed-group-inner mini-repo-list">
        <li class="public source ">
          <a href="http://github.com/jessesquires/JSQCoreDataKit" class="mini-repo-list-item css-truncate">
            <span class="repo" title="JSQCoreDataKit">JSQCoreDataKit</span>
            <span class="stars">
              357
              <span class="oction oction-star"></span>
            </span>
            <span class="repo-description css-truncate-target">A swifter Core Data stack</span>
          </a>
        </li>
    </div>
```

We can initialize an HTML document from string:

```swift
let document = HTMLDocument(html: htmlString, encoding: .utf8)
```

We then can access its contents by querying it using XPath:

```swift
let element = document.element(atXPath: "//span[@class='stars']")

print(element.text)

// Prints "357".

print(element.html)

// Prints:
// <span class="stars">
//               357
//               <span class="oction oction-star"></span>
//             </span>
```

…or CSS selector:

```swift
let element = document.element(atCSSSelector: "span.stars")

print(element.text)

// Prints "357".

print(element.html)

// Prints:
// <span class="stars">
//               357
//               <span class="oction oction-star"></span>
//             </span>
```

We can even change the contents:

```swift
let element = document.element(atXPath: "//span[@class='repo']")

element["title"] = "Scrape"
element.content = "Scrape"

print(element.html)

// Prints:
// <span class="repo" title="Scrape">Scrape</span>
```
It is also possible to reorder nodes, provide parsing options and convert CSS selectors to XPath queries.

## Documentation

Available [here](https://sjtba.github.io/Scrape/).

## Why not Kanna?

[Kanna](https://github.com/tid-kijyun/Kanna) can be used on Apple platforms only, while Scrape can be used
in Linux environment. Scrape also provides more consistent and clearer API, and also a better test coverage.
And the most important — there is a complete documentation with examples!


