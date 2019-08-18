//
//  Spitfire.swift
//  Spitfire
//
//  Created by seanmcneil on 8/17/19.
//

import AVFoundation
import UIKit

public protocol SpitfireDelegate: class {
    func videoProgress(progress: Progress)
    func videoCompleted(url: URL)
    func videoFailed(error: SpitfireError)
}

public class Spitfire {
    private weak var delegate: SpitfireDelegate?
    
    private var videoWriter: AVAssetWriter?
    private var writer: Writer?
    
    private var outputURL: URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentURL = URL(fileURLWithPath: documentsPath)
        
        return documentURL.appendingPathComponent("output.mov")
    }
    
    /// Creates a Spitfire object with the provided delegate
    ///
    /// - Parameter delegate: Delegate to handle status updates
    public init(delegate: SpitfireDelegate) {
        self.delegate = delegate
    }
    
    /// Performs creation of video from provided images
    ///
    /// - Parameters:
    ///   - images: [UIimage], all images must be the same size
    ///   - fps: Framerate, default value is 30 & must be 1...60
    public func makeVideo(with images: [UIImage],
                          fps: Int32 = 30) {
        guard let size = images.first?.size else {
            delegate?.videoFailed(error: .imageArrayEmpty)
            
            return
        }
        
        guard fps > 0 && fps <= 60 else {
            let message = NSLocalizedString("Framerate must be between 1 and 60", comment: "")
            delegate?.videoFailed(error: .invalidFramerate(message))
            
            return
        }
        
        guard size.width.truncatingRemainder(dividingBy: 16.0) == 0 else {
            let message = NSLocalizedString("Image width must be divisble by 16", comment: "")
            delegate?.videoFailed(error: .imageDimensionsMultiplierFailure(message))
            
            return
        }
        
        let videoData = VideoData(fps: fps,
                                  size: size,
                                  url: outputURL)

        try? FileManager.default.removeItem(at: videoData.url)
        
        do {
            try videoWriter = AVAssetWriter(outputURL: videoData.url,
                                            fileType: .mov)
        } catch {
            print(error)
            delegate?.videoFailed(error: .videoWriterFailure)
            
            return
        }
        
        guard let videoWriter = videoWriter else {
            delegate?.videoFailed(error: .videoWriterFailure)
            
            return
        }

        let videoWriterInput = AVAssetWriterInput(mediaType: .video,
                                                  outputSettings: videoData.videoSettings)

        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoWriterInput,
            sourcePixelBufferAttributes: videoData.sourceBufferAttributes
        )
        
        assert(videoWriter.canAdd(videoWriterInput))
        videoWriter.add(videoWriterInput)
        
        if videoWriter.startWriting() {
            writer = Writer(videoWriter: videoWriter,
                            pixelBufferAdaptor: pixelBufferAdaptor,
                            videoWriterInput: videoWriterInput)
            writer?.write(images: images,
                          videoData: videoData,
                          delegate: delegate)
        }
    }
}
