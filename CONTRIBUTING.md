# Contributing to Maplibre Directions for Swift

## Reporting an issue

Bug reports and feature requests are more than welcome, but please consider the following tips so we can respond to your feedback more effectively.

Before reporting a bug here, please determine whether the issue lies with the MaplibreDirections package or with another Maplibre/Mapbox  product:

When reporting a bug in the client-side MaplibreDirections package, please indicate:

* The version of MaplibreDirections you installed
* The version of CocoaPods, Carthage, or Swift Package Manager that you used to install the package
* The version of Xcode you used to build the package
* The operating system version and device model on which you experienced the issue
* Any relevant settings in `RouteOptions` or `MatchOptions`

## Setting up a development environment

To contribute code changes to this project, use either Carthage or Swift Package Manager to set up a development environment. Carthage and the Xcode project in this repository are important for Apple platforms, particularly for making sure dependent projects can use Carthage. Swift Package Manager is particularly important for Linux.

### Using Carthage

1. Install Xcode 13 and [Carthage](https://github.com/Carthage/Carthage/) v0.38 or above.
1. Run `carthage bootstrap --platform all --use-xcframeworks`.
1. Once the Carthage build finishes, open MapboxDirections.xcodeproj in Xcode and build the MapboxDirections Mac scheme.

### Using Swift Package Manager

In Xcode, go to Source Control ‣ Clone, enter `https://github.com/maplibe/maplibre-directions-swift.git`, and click Clone.

Alternatively, on the command line:

```bash
git clone https://github.com/mapbox/mapbox-directions-swift.git
cd mapbox-directions-swift/
open Package.swift
```

## Making any symbol public

To add any type, constant, or member to the package’s public interface:

1. Name the symbol according to [Swift design guidelines](https://swift.org/documentation/api-design-guidelines/) and [Cocoa naming conventions](https://developer.apple.com/library/prerelease/content/documentation/Cocoa/Conceptual/CodingGuidelines/CodingGuidelines.html#//apple_ref/doc/uid/10000146i). This library does not bridge to Objective-C, so the Swift design guidelines matter more than the traditional Cocoa naming conventions. Either way, this package often intentionally differs from the vocabulary and structure of the Mapbox Directions API.
1. Provide full documentation comments. We use [jazzy](https://github.com/realm/jazzy/) to produce the documentation found [on the website for this package](https://docs.mapbox.com/ios/api/directions/). Many developers also rely on Xcode’s Quick Help feature, which supports a subset of Markdown.
1. _(Optional.)_ Add the type or constant’s name to the relevant category in the `custom_categories` section of [the jazzy configuration file](./docs/jazzy.yml). This is required for classes and protocols and also recommended for any other type that is strongly associated with a particular class or protocol. If you leave out this step, the symbol will appear in an “Other” section in the generated HTML documentation’s table of contents.

## Adding tests

### Adding a test suite

1. Add a file to Tests/MapboxDirectionsTests/
1. Add a file reference to the MapboxDirectionsTests group in MapboxDirections.xcodeproj.

### Adding a test case

1. Add a `test*` method to one of the classes in one of the files in [Tests/MapboxDirectionsTests/](./Tests/MapboxDirectionsTests/).

### Adding a test fixture

1. Add a file to [Tests/MapboxDirectionsTests/Fixtures/](./Tests/MapboxDirectionsTests/Fixtures/).
1. Inside a test case, call `Fixture.stringFromFileNamed(name:)` or `Fixture.JSONFromFileNamed(name:)`.

### Running unit tests

Go to Product ‣ Test in Xcode, or run `swift test` on the command line.

## Opening a pull request

Pull requests are appreciated. If your PR includes any changes that would impact developers or end users, please mention those changes in the “main” section of [CHANGELOG.md](CHANGELOG.md), noting the PR number. Examples of noteworthy changes include new features, fixes for user-visible bugs, and renamed or deleted public symbols.

Before we can merge your PR, it must pass automated continuous integration checks on each of the supported platforms, as well as a check to ensure that code coverage has not decreased significantly.

## Setup for creating pull requests

* Fork this project
* In your fork, create a branch, for example: fix/camera-update
* Add your changes
* Push and open a PR with your branch
