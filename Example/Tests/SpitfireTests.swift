//
//  SpitfireTests.swift
//  Spitfire
//
//  Created by seanmcneil on 3/26/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import XCTest
import UIKit

@testable import Spitfire

class SpitfireTests: XCTestCase {
    func testInitEmptyArray() {
        let spitfire = Spitfire()
        let emptyArray = [UIImage]()
        
        XCTAssertThrowsError(try spitfire.makeVideo(with: emptyArray, progress: { (progress) in
            XCTFail()
        }, success: { (url) in
            XCTFail()
        })) { error -> Void in
            switch error {
            case SpitfireError.ImageArrayEmpty:
                break
            default:
                XCTFail("Incorrect error type")
            }
        }
    }
    
    func testFrameRateTooLow() {
        let spitfire = Spitfire()
        let lowFPS: Int32 = 0
        let array = [UIImage()]
        
        XCTAssertThrowsError(try spitfire.makeVideo(with: array, fps:lowFPS, progress: { (progress) in
            XCTFail()
        }, success: { (url) in
            XCTFail()
        })) { error -> Void in
            switch error {
            case SpitfireError.InvalidFramerate("Framerate must be between 1 and 60"):
                break
            default:
                XCTFail("Incorrect error type")
            }
        }
    }
    
    func testFrameRateTooHigh() {
        let spitfire = Spitfire()
        let lowFPS: Int32 = 61
        let array = [UIImage()]
        
        XCTAssertThrowsError(try spitfire.makeVideo(with: array, fps:lowFPS, progress: { (progress) in
            XCTFail()
        }, success: { (url) in
            XCTFail()
        })) { error -> Void in
            switch error {
            case SpitfireError.InvalidFramerate("Framerate must be between 1 and 60"):
                break
            default:
                XCTFail("Incorrect error type")
            }
        }
    }
    
    func testDivisbleBy16() {
        let spitfire = Spitfire()
        let images: [UIImage] = [UIImage(color: .black)!]
        
        XCTAssertThrowsError(try spitfire.makeVideo(with: images, progress: { (progress) in
            XCTFail()
        }, success: { (url) in
            XCTFail()
        })) { error -> Void in
            switch error {
            case SpitfireError.ImageDimensionsMultiplierFailure("Image width must be divisble by 16"):
                break
            default:
                XCTFail("Incorrect error type")
            }
        }
    }


    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        
        self.init(cgImage: cgImage)
    }
}
