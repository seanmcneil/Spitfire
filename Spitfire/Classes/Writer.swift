//
//  Writer.swift
//  Spitfire
//
//  Created by seanmcneil on 8/17/19.
//

import AVFoundation

final class Writer {
    private let videoWriter: AVAssetWriter
    private let pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor
    private let videoWriterInput: AVAssetWriterInput
    
    private let writeQueue = DispatchQueue(label: "writequeue", qos: .background)
    
    /// Initializes writer object with objects for handling video writing work
    ///
    /// - Parameters:
    ///   - videoWriter: Service for writing to new file
    ///   - pixelBufferAdaptor: Provides interface for appending samples to AVAssetWriterInput
    ///   - videoWriterInput: Provides interface for appending samples to AVAssetWriter
    init(videoWriter: AVAssetWriter,
         pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor,
         videoWriterInput: AVAssetWriterInput) {
        self.videoWriter = videoWriter
        self.pixelBufferAdaptor = pixelBufferAdaptor
        self.videoWriterInput = videoWriterInput
    }
    
    /// Starts process of writing frames to file
    ///
    /// - Parameters:
    ///   - images: [UIImage] for creating video
    ///   - videoData: Contains information for configuring video
    ///   - delegate: Delegate to handle status updates
    func write(images: [UIImage],
               videoData: VideoData,
               delegate: SpitfireDelegate?) {
        videoWriter.startSession(atSourceTime: .zero)
        assert(pixelBufferAdaptor.pixelBufferPool != nil)
        
        videoWriterInput.requestMediaDataWhenReady(on: writeQueue,
                                                   using: { [weak self] in
                                                    self?.writeFrames(images: images,
                                                                      videoData: videoData,
                                                                      delegate: delegate)
        })
    }
    
    /// Handles writing of frames to video file
    ///
    /// - Parameters:
    ///   - images: [UIImage] for creating video
    ///   - videoData: Contains information for configuring video
    ///   - delegate: Delegate to handle status updates
    private func writeFrames(images: [UIImage],
                             videoData: VideoData,
                             delegate: SpitfireDelegate?) {
        let frameDuration = CMTimeMake(value: 1, timescale: videoData.fps)
        let currentProgress = Progress(totalUnitCount: Int64(images.count))
        var frameCount: Int64 = 0
        
        while(Int(frameCount) < images.count) {
            // Will continue to loop until the video writer is able to write, which effectively handles buffer backups
            if videoWriterInput.isReadyForMoreMediaData {
                assert(!Thread.isMainThread)
                let lastFrameTime = CMTimeMake(value: frameCount, timescale: videoData.fps)
                let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
                var image = images[Int(frameCount)]
                
                guard image.size == videoData.size else {
                    delegate?.videoFailed(error: .imageDimensionsMatchFailure)
                    
                    return
                }
                
                if append(pixelBufferAdaptor: pixelBufferAdaptor,
                          with: &image,
                          at: presentationTime,
                          delegate: delegate) {
                    frameCount += 1
                    currentProgress.completedUnitCount = frameCount
                    delegate?.videoProgress(progress: currentProgress)
                }
            }
        }
        
        videoWriterInput.markAsFinished()
        videoWriter.finishWriting {
            delegate?.videoCompleted(url: videoData.url)
        }
    }
    
    /// Set up pixel buffer to add a frame at specified time
    ///
    /// - Parameters:
    ///   - adaptor: Provides interface for appending samples to AVAssetWriterInput
    ///   - image: UIImage to write, passed in by reference
    ///   - presentationTime: Time value for marking position in video
    ///   - delegate: Delegate to handle status updates
    /// - Returns: Bool that indicates if operation was successful
    private func append(pixelBufferAdaptor adaptor: AVAssetWriterInputPixelBufferAdaptor,
                with image: inout UIImage,
                at presentationTime: CMTime,
                delegate: SpitfireDelegate?) -> Bool {
        if let pixelBufferPool = adaptor.pixelBufferPool {
            let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)
            let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, pixelBufferPointer)
            guard var pixelBuffer = pixelBufferPointer.pointee else {
                delegate?.videoFailed(error: .pixelBufferPointeeFailure)
                
                return false
            }
            
            guard status == 0 else {
                delegate?.videoFailed(error: .invalidStatusCode(Int(status)))
                
                return false
            }
            
            fill(pixelBuffer: &pixelBuffer, with: &image)
            if adaptor.append(pixelBuffer, withPresentationTime: presentationTime) {
                pixelBufferPointer.deinitialize(count: 1)
                pixelBufferPointer.deallocate()
                return true
            } else {
                delegate?.videoFailed(error: .pixelBufferApendFailure)
            }
        }
        
        return false
    }
    
    /// Populates the pixel buffer with the contents of the current image
    ///
    /// - Parameters:
    ///   - buffer: Memory storage for pixel buffer, passed in by reference
    ///   - image: UIImage to write, passed in by reference
    private func fill(pixelBuffer buffer: inout CVPixelBuffer,
                      with image: inout UIImage) {
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue),
            let cgImage = image.cgImage else {
                return
        }
        
        let rect = CGRect(origin: .zero, size: image.size)
        context.draw(cgImage, in: rect)
        
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
    }
}
