//
//  Spitfire.swift
//  Pods
//
//  Created by seanmcneil on 3/8/17.
//
//

import AVFoundation
import UIKit

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

public class Spitfire {
    public init() { }
    
    private var videoWriter: AVAssetWriter?
    
    private var outputURL: URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentURL = URL(fileURLWithPath: documentsPath)
        
        return documentURL.appendingPathComponent("output.mov")
    }
    
    /// Produces a video based on the contents of a UIImage array
    ///
    /// - Parameters:
    ///   - images: Images to use for creating video. Should all have the same dimensions
    ///   - fps: Frames per second, with a default value of 30
    ///   - progress: Handler that will return a fractional value indicating percent complete
    ///   - success: Handler that will return a URL of the completed video if successful
    ///   - failure: Handler that will return an error message if one occurs
    public func makeVideo(with images: [UIImage], fps: Int32 = 30, progress: @escaping ((Progress) -> ()), success: @escaping ((URL) -> ()), failure: @escaping ((Error) -> ())) {
        guard let size = images.first?.size else {
            failure(SpitfireError.ImageArrayEmpty)
            
            return
        }
        
        guard fps > 0 && fps <= 60 else {
            let message = NSLocalizedString("Framerate must be between 1 and 60", comment: "")
            failure(SpitfireError.InvalidFramerate(message))
            
            return
        }
        
        guard (size.width .truncatingRemainder(dividingBy: 16.0)) == 0 else {
            let message = NSLocalizedString("Image width must be divisble by 16", comment: "") 
            failure(SpitfireError.ImageDimensionsMultiplierFailure(message))
            
            return
        }
        
        do {
            try FileManager.default.removeItem(at: outputURL)
        } catch {
            failure(error)
        }
        
        do {
            try videoWriter = AVAssetWriter(outputURL: outputURL, fileType: AVFileTypeQuickTimeMovie)
        } catch {
            failure(error)
        }
        
        guard let videoWriter = videoWriter else {
            failure(SpitfireError.VideoWriterFailure)
            
            return
        }
        
        let videoSettings: [String : Any] = [
            AVVideoCodecKey  : AVVideoCodecH264,
            AVVideoWidthKey  : size.width,
            AVVideoHeightKey : size.height,
            ]
        
        let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: videoSettings)
        
        let sourceBufferAttributes: [String : Any] = [
            (kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32ARGB),
            (kCVPixelBufferWidthKey as String): Float(size.width),
            (kCVPixelBufferHeightKey as String): Float(size.height)]
        
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoWriterInput,
            sourcePixelBufferAttributes: sourceBufferAttributes
        )
        
        assert(videoWriter.canAdd(videoWriterInput))
        videoWriter.add(videoWriterInput)
        
        if videoWriter.startWriting() {
            videoWriter.startSession(atSourceTime: kCMTimeZero)
            assert(pixelBufferAdaptor.pixelBufferPool != nil)
            let writeQueue = DispatchQueue(label: "writeQueue")
            videoWriterInput.requestMediaDataWhenReady(on: writeQueue, using: { [weak self] () -> Void in
                let frameDuration = CMTimeMake(1, fps)
                let currentProgress = Progress(totalUnitCount: Int64(images.count))
                
                var frameCount: Int64 = 0
                
                while (Int(frameCount) < images.count) {
                    if videoWriterInput.isReadyForMoreMediaData {
                        let lastFrameTime = CMTimeMake(frameCount, fps)
                        let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
                        let appendImage = images[Int(frameCount)]
                        
                        guard appendImage.size == size else {
                            failure(SpitfireError.ImageDimensionsMatchFailure)
                            
                            return
                        }

                        self?.appendPixelBuffer(for: appendImage, pixelBufferAdaptor: pixelBufferAdaptor, presentationTime: presentationTime, success: {
                            frameCount += 1
                            currentProgress.completedUnitCount = frameCount
                            progress(currentProgress)
                        }, failure: { (error) in
                            print(error.localizedDescription)
                        })
                    }
                }
                
                videoWriterInput.markAsFinished()
                videoWriter.finishWriting { [weak self] () -> Void in
                    guard let strongSelf = self else { return }
                    
                    success(strongSelf.outputURL)
                }
            })
        }
    }
}

fileprivate extension Spitfire {
    func appendPixelBuffer(for image: UIImage, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, presentationTime: CMTime, success: @escaping (() -> Void), failure: ((Error) -> Void)) {
        autoreleasepool {
            if let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool {
                let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)
                let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, pixelBufferPointer)
                guard let pixelBuffer = pixelBufferPointer.pointee else {
                    failure(SpitfireError.PixelBufferPointeeFailure)
                    
                    return
                }
                guard status == 0 else {
                    failure(SpitfireError.InvalidStatusCode(Int(status)))
                    
                    return
                }
                
                fillPixelBufferFromImage(image: image, pixelBuffer: pixelBuffer)
                if pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime) {
                    pixelBufferPointer.deinitialize()
                    pixelBufferPointer.deallocate(capacity: 1)
                    success()
                } else {
                    failure(SpitfireError.PixelBufferApendFailure)
                }
            }
        }
    }
    
    func fillPixelBufferFromImage(image: UIImage, pixelBuffer: CVPixelBuffer) {
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(pixelBuffer),
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
            ) else { return }
        guard let cgImage = image.cgImage else { return }
        
        let rect = CGRect(origin: .zero, size: image.size)
        context.draw(cgImage, in: rect)
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
    }
}
