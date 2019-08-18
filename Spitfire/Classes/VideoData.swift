//
//  VideoData.swift
//  Spitfire
//
//  Created by seanmcneil on 8/17/19.
//

import AVFoundation

struct VideoData {
    let fps: Int32
    let size: CGSize
    let url: URL
    
    var videoSettings: [String : Any] {
        return
            [AVVideoCodecKey  : AVVideoCodecType.h264,
             AVVideoWidthKey  : size.width,
             AVVideoHeightKey : size.height]
    }
    
    var sourceBufferAttributes: [String : Any] {
        return
            [(kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32ARGB),
             (kCVPixelBufferWidthKey as String): Float(size.width),
             (kCVPixelBufferHeightKey as String): Float(size.height)]
    }
}
