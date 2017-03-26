//
//  Errors.swift
//  Pods
//
//  Created by seanmcneil on 3/26/17.
//
//

import Foundation

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
