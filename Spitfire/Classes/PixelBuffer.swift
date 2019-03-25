//
//  PixelBuffer.swift
//  Pods
//
//  Created by seanmcneil on 3/26/17.
//
//

import AVFoundation

extension Spitfire {
    // Set up pixel buffer to add a frame at specified time
    func append(pixelBufferAdaptor adaptor: AVAssetWriterInputPixelBufferAdaptor, with image: UIImage, at presentationTime: CMTime, success: @escaping (() -> ())) throws {
        do {
            if let pixelBufferPool = adaptor.pixelBufferPool {
                let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)
                let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, pixelBufferPointer)
                guard let pixelBuffer = pixelBufferPointer.pointee else {
                    throw(SpitfireError.PixelBufferPointeeFailure)
                }
                guard status == 0 else {
                    throw(SpitfireError.InvalidStatusCode(Int(status)))
                }
                
                fill(pixelBuffer: pixelBuffer, with: image)
                if adaptor.append(pixelBuffer, withPresentationTime: presentationTime) {
                    pixelBufferPointer.deinitialize(count: 1)
                    pixelBufferPointer.deallocate()
                    success()
                } else {
                    throw(SpitfireError.PixelBufferApendFailure)
                }
            }
        } catch let error {
            throw error
        }
    }
    
    // Populates the pixel buffer with the contents of the current image
    private func fill(pixelBuffer buffer: CVPixelBuffer, with image: UIImage) {
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
            ) else { return }
        guard let cgImage = image.cgImage else { return }
        
        let rect = CGRect(origin: .zero, size: image.size)
        context.draw(cgImage, in: rect)
        
        CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
    }
}
