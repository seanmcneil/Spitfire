# Spitfire

![Spitfire: Seamlessly create videos from images](https://raw.githubusercontent.com/seanmcneil/Spitfire/master/spitfire.jpg)

[![CI Status](http://img.shields.io/travis/seanmcneil/Spitfire.svg?style=flat)](https://travis-ci.org/seanmcneil/Spitfire)
[![Version](https://img.shields.io/cocoapods/v/Spitfire.svg?style=flat)](http://cocoapods.org/pods/Spitfire)
[![License](https://img.shields.io/cocoapods/l/Spitfire.svg?style=flat)](http://cocoapods.org/pods/Spitfire)
[![Platform](https://img.shields.io/cocoapods/p/Spitfire.svg?style=flat)](http://cocoapods.org/pods/Spitfire)

Spitfire is a simple utility for taking an array of images and creating a video from them.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

The following code can be found in the example project, but demonstrates how to call it and handle the various callbacks it supports.

To initialize an instance of Spitfire, you must provide a delegate. A common way of doing this within a UIViewController would be to use a lazy property like this:
```swift
lazy var spitfire: Spitfire = {
    return Spitfire(delegate: self)
}()
```

And a function for creating the video, using [UIImage] called images, and with a framerate of 30 fps:

```swift
spitfire.makeVideo(with: images, fps: 30)
```
Spitfire will return feedback via a set of delegate functions. This includes the following:
- Progress status
- Completion, including URL
- Failure, including error

The Spitfire delegate protocol:
```swift
public protocol SpitfireDelegate: class {
    func videoProgress(progress: Progress)
    func videoCompleted(url: URL)
    func videoFailed(error: SpitfireError)
}
```
## Performance Considerations

Be aware that the image array to feed the writer can start to get immense, easily exceeding 1GB of RAM

## Requirements
- iOS 11.0+
- Xcode 10.2+
- Swift 5.0+

## Installation

Spitfire is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Spitfire"
```

## Usage

```swift
import Spitfire
```

Ensure that you declare the Spitfire property at the class level so that it does not go out of scope during execution:

```swift
class MyClass {
    lazy var spitfire: Spitfire = {
        return Spitfire(delegate: self)
    }()
    ...
}
```

Call the default makeVideo function, and accept the default value of 30 for framerate:

```swift
spitfire.makeVideo(with: images)
``` 

Call the optional makeVideo function and specify a frame rate between 1 and 60:

```swift
spitfire.makeVideo(with: images, fps: 60)
``` 

## Errors

Spitfire provides a relatively rich set of errors via an enum that should address all potential failures within the app. These are:

```swift
public enum SpitfireError: Swift.Error {
    case imageArrayEmpty
    case invalidFramerate(String)
    case imageDimensionsMatchFailure
    case imageDimensionsMultiplierFailure(String)
    case videoWriterFailure
    case pixelBufferPointeeFailure
    case invalidStatusCode(Int)
    case pixelBufferApendFailure
}
```

## Credits

This work is based off of work originally performed by [acj](https://gist.github.com/acj) which can be found [here](https://gist.github.com/acj/6ae90aa1ebb8cad6b47b).

## License

Spitfire is available under the MIT license. See the LICENSE file for more info.
