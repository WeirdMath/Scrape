import PackageDescription

let package = Package(
    name: "Scrape",
    dependencies: [
        .Package(url: "https://github.com/WeirdMath/CLibxml2.git", majorVersion: 1)
    ]
)
