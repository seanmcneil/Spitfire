//
//  PixelBuffer.swift
//  Pods
//
//  Created by seanmcneil on 3/26/17.
//
//

import AVFoundation

extension Spitfire {
    func appendPixelBuffer(for image: UIImage, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, presentationTime: CMTime, success: @escaping (() -> Void)) throws {
        do {
            if let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool {
                let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)
                let status = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, pixelBufferPointer)
                guard let pixelBuffer = pixelBufferPointer.pointee else {
                    throw(SpitfireError.PixelBufferPointeeFailure)
                }
                guard status == 0 else {
                    throw(SpitfireError.InvalidStatusCode(Int(status)))
                }
                
                fillPixelBufferFromImage(image: image, pixelBuffer: pixelBuffer)
                if pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime) {
                    pixelBufferPointer.deinitialize()
                    pixelBufferPointer.deallocate(capacity: 1)
                    success()
                } else {
                    throw(SpitfireError.PixelBufferApendFailure)
                }
            }
        } catch let error {
            throw error
        }
    }
    
    private func fillPixelBufferFromImage(image: UIImage, pixelBuffer: CVPixelBuffer) {
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
