//
//  CriaError.swift
//  Cria
//
//  Created by Elias Abel on 06/04/16.
//  Copyright © 2016 Meniny Lab. All rights reserved.
//


import Foundation

public struct CriaError: Error {

    public enum Status: Int {
        case unknown                        = -1
        case networkUnreachable             = 0
        
        case unableToParseResponse          = 1
        
        // 4xx Client Error
        case badRequest                     = 400
        case unauthorized                   = 401
        case paymentRequired                = 402
        case forbidden                      = 403
        case notFound                       = 404
        case methodNotAllowed               = 405
        case notAcceptable                  = 406
        case proxyAuthenticationRequired    = 407
        case requestTimeout                 = 408
        case conflict                       = 409
        case gone                           = 410
        case lengthRequired                 = 411
        case preconditionFailed             = 412
        case payloadTooLarge                = 413
        case uriTooLong                     = 414
        case unsupportedMediaType           = 415
        case rangeNotSatisfiable            = 416
        case expectationFailed              = 417
        case teapot                         = 418
        case misdirectedRequest             = 421
        case unprocessableEntity            = 422
        case locked                         = 423
        case failedDependency               = 424
        case upgradeRequired                = 426
        case preconditionRequired           = 428
        case tooManyRequests                = 429
        case requestHeaderFieldsTooLarge    = 431
        case unavailableForLegalReasons     = 451
        
        // 4xx nginx
        case noResponse                     = 444
        case sslCertificateError            = 495
        case sslCertificateRequired         = 496
        case httpRequestSentToHTTPSPort     = 497
        case clientClosedRequest            = 499
        
        // 5xx Server Error
        case internalServerError            = 500
        case notImplemented                 = 501
        case badGateway                     = 502
        case serviceUnavailable             = 503
        case gatewayTimeout                 = 504
        case httpVersionNotSupported        = 505
        case variantAlsoNegotiates          = 506
        case insufficientStorage            = 507
        case loopDetected                   = 508
        case notExtended                    = 510
        case networkAuthenticationRequired  = 511
    }
    
    public var status: Status
    public var code: Int { return status.rawValue }
    
    public init(httpStatusCode: Int) {
        self.status = Status(rawValue: httpStatusCode) ?? .unknown
    }
    
}

extension CriaError: CustomStringConvertible {
    
    public var description: String {
        return String(describing: self.status)
            .replacingOccurrences(of: "(?<=[a-z])(?=[A-Z])|(?<=[A-Z])(?=[A-Z][a-z])",
                                  with: " ",
                                  options: [.regularExpression])
            .capitalized
    }
    
}

extension CriaError {
    
    public static var unableToParseResponse: CriaError {
        return CriaError(httpStatusCode: Status.unableToParseResponse.rawValue)
    }
    
}
