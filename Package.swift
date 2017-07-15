import PackageDescription

let v5 = Version(5,0,0, prereleaseIdentifiers: ["alpha8"])

let pkg = Package(
    name: "PMKFoundation",
    dependencies: [
        .Package(url: "https://github.com/mxcl/PromiseKit.git", v5)
    ],
    exclude: [
        "Sources/NSNotificationCenter+AnyPromise.m",
        "Sources/NSTask+AnyPromise.m",
        "Sources/NSURLSession+AnyPromise.m",
        "Sources/PMKFoundation.h",
		"Tests"  // currently SwiftPM is not savvy to having a single test…
    ]
)

pkg.swiftLanguageVersions = [3,4]
