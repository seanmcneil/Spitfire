# Spitfire

![Spitfire: Seamlessly create videos from images](https://raw.githubusercontent.com/seanmcneil/Spitfire/master/spitfire.jpg)

[![CI Status](http://img.shields.io/travis/seanmcneil/Spitfire.svg?style=flat)](https://travis-ci.org/seanmcneil/Spitfire)
[![Version](https://img.shields.io/cocoapods/v/Spitfire.svg?style=flat)](http://cocoapods.org/pods/Spitfire)
[![License](https://img.shields.io/cocoapods/l/Spitfire.svg?style=flat)](http://cocoapods.org/pods/Spitfire)
[![Platform](https://img.shields.io/cocoapods/p/Spitfire.svg?style=flat)](http://cocoapods.org/pods/Spitfire)
[![CocoaPods](https://img.shields.io/cocoapods/dt/Spitfire.svg)](http://cocoapods.org/pods/Spitfire)

Spitfire is a simple utility for taking an array of images and creating a video from them.

## Current Status

All previous beta versions have been removed from the repository, as they do not comply with the current design.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

The following code can be found in the example project, but demonstrates how to call it and handle the various callbacks it supports:

```swift
let spitfire = Spitfire()
```

And a function for creating the video:

```swift
func createVideo(for images: [UIImage]) {
    do {
        try spitfire.makeVideo(with: images, progress: { (progress) in
            let percent = (progress.fractionCompleted * 100).roundTo(places: 2)
            print("\(percent)%")
        }, success: { (url) in
            PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { saved, error in
                if saved {
                    let alertController = UIAlertController(title: NSLocalizedString("Your video was saved", comment: ""), message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        })
    } catch {
        print(error.localizedDescription)
    }
}
```

## Performance Considerations

Be aware that the image array to feed the writer can start to get immense, easily exceeding 1GB of RAM

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
```

Ensure that you declare the Spitfire property at the class level so that it does not go out of scope during execution:

```swift
class MyClass {
    let spitfire = Spitfire()
    ...
```

Call the default makeVideo function, which uses a value of 30 for frame rate:

```swift
do {
    try spitfire.makeVideo(with: images, progress: { (progress) in
        // Update user on status
    }, success: { (url) in
        // Process the completed video
    })
} catch {
    // Handle any errors
}
``` 

Call the optional makeVideo function and specify a frame rate between 1 and 60:

```swift
do {
    try spitfire.makeVideo(with: images, fps: 5, progress: { (progress) in
        // Update user on status
    }, success: { (url) in
        // Process the completed video
    })
} catch {
    // Handle any errors
}
``` 

## Errors

Spitfire provides a relatively rich set of errors via an enum that should address all potential failures within the app. These are:

```swift
public enum SpitfireError: Swift.Error {
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
