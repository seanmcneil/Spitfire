# Spitfire

![Spitfire: Seamlessly create videos from images](https://raw.githubusercontent.com/seanmcneil/Spitfire/master/spitfire.jpg)

[![CI Status](http://img.shields.io/travis/seanmcneil/Spitfire.svg?style=flat)](https://travis-ci.org/seanmcneil/Spitfire)
[![Version](https://img.shields.io/cocoapods/v/Spitfire.svg?style=flat)](http://cocoapods.org/pods/Spitfire)
[![License](https://img.shields.io/cocoapods/l/Spitfire.svg?style=flat)](http://cocoapods.org/pods/Spitfire)
[![Platform](https://img.shields.io/cocoapods/p/Spitfire.svg?style=flat)](http://cocoapods.org/pods/Spitfire)
[![CocoaPods](https://img.shields.io/cocoapods/dt/Spitfire.svg)](http://cocoapods.org/pods/Spitfire)

Spitfire is a simple utility for taking an array of images and creating a video from them.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
- iOS 8.3+
- Xcode 8.0+
- Swift 3.0+

## Installation

Spitfire is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Spitfire"
```

## Usage

```swift
import Spitfire

Spitfire.shared.makeVideo(with: <#T##[UIImage]#>, progress: <#T##((Progress) -> Void)##((Progress) -> Void)##(Progress) -> Void#>, success: <#T##((URL) -> Void)##((URL) -> Void)##(URL) -> Void#>, failure: <#T##((Error) -> Void)##((Error) -> Void)##(Error) -> Void#>)
``` 

The default makeVideo method will apply a framerate of 30 fps. Optionally, you can specify one between 1 - 60 fps:

```swift
Spitfire.shared.makeVideo(with: <#T##[UIImage]#>, fps: <#T##Int32#>, progress: <#T##((Progress) -> Void)##((Progress) -> Void)##(Progress) -> Void#>, success: <#T##((URL) -> Void)##((URL) -> Void)##(URL) -> Void#>, failure: <#T##((Error) -> Void)##((Error) -> Void)##(Error) -> Void#>)
```

## Errors

Spitfire provides a relatively rich set of errors via an enum that should address all potential failures within the app. These are:

```swift
public enum SpitfireError: Error {
case ImageArrayEmpty
case InvalidFramerate(String)
case ImageDimensionsMatchFailure
case ImageDimensionsMultiplierFailure(String)
case VideoWriterFailure
case PixelBufferPointeeFailure
case InvalidStatusCode(Int)
case PixelBufferApendFailure
}
```

## Credits

This work is based off of work originally performed by [acj](https://gist.github.com/acj) which can be found [here](https://gist.github.com/acj/6ae90aa1ebb8cad6b47b).

## License

Spitfire is available under the MIT license. See the LICENSE file for more info.
