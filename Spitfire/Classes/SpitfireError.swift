//
//  SpitfireError.swift
//  Spitfire
//
//  Created by seanmcneil on 8/17/19.
//

import Foundation

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
