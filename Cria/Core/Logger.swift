//
//  Cria.Logger.swift
//  Cria
//
//  Created by Elias Abel on 13/11/2016.
//  Copyright © 2016 Meniny Lab. All rights reserved.
//

import Alamofire
import Foundation

public extension Cria {
    open class Logger {
        
        public enum Level {
            
            @available(*, unavailable, renamed: "off")
            case none
            @available(*, unavailable, renamed: "info")
            case calls
            @available(*, unavailable, renamed: "debug")
            case callsAndResponses
            
            case off
            case info
            case debug
        }
        
        open var logLevels = Cria.Logger.Level.off
        
        open func logMultipartRequest(_ request: Cria.Request) {
            guard logLevels != .off else {
                return
            }
            var printParts = [String]()
            printParts.append("\(request.method.rawValue.uppercased()) '\(request.fullURL)'")
            printParts.append("  params : \(request.params)")
            
            for (k, v) in request.headers {
                printParts.append("  \(k) : \(v)")
            }
            for multipart in request.multipartData {
                printParts.append("  name : \(multipart.name)," + "mimeType: \(multipart.mimetype ?? "N/A"), filename: \(multipart.filename ?? "N/A")")
            }
            //        if logLevels == .debug {
            //
            //        }
            print(printParts.joined(separator: "\n"))
        }
        
        open func logRequest(_ request: DataRequest) {
            guard logLevels != .off else {
                return
            }
            if let urlRequest = request.request, let verb = urlRequest.httpMethod, let url = urlRequest.url {
                print("\(verb) '\(url.absoluteString)'")
                logHeaders(urlRequest)
                logBody(urlRequest)
                //            if logLevels == .debug {
                //                print()
                //            }
            }
        }
        
        open func logResponse(_ response: DefaultDataResponse) {
            guard logLevels != .off else {
                return
            }
            logStatusCodeAndURL(response.response)
            //        if logLevels == .debug {
            //            print()
            //        }
        }
        
        open func logDownloadResponse(_ response: DefaultDownloadResponse) {
            guard logLevels != .off else {
                return
            }
            logStatusCodeAndURL(response.response)
            //        if logLevels == .debug {
            //            print()
            //        }
        }
        
        open func logResponse(_ response: DataResponse<Any>) {
            guard logLevels != .off else {
                return
            }
            logStatusCodeAndURL(response.response)
            if logLevels == .debug {
                switch response.result {
                case .success(let value):
                    print(value)
                case .failure(let error):
                    print(error)
                }
            }
            //        if logLevels == .debug {
            //            print()
            //        }
        }
        
        private func logHeaders(_ urlRequest: URLRequest) {
            if let allHTTPHeaderFields = urlRequest.allHTTPHeaderFields {
                for (k, v) in allHTTPHeaderFields {
                    print("  \(k) : \(v)")
                }
            }
        }
        
        private func logBody(_ urlRequest: URLRequest) {
            if let body = urlRequest.httpBody,
                let str = String(data: body, encoding: .utf8) {
                print("  HttpBody : \(str)")
            }
        }
        
        private func logStatusCodeAndURL(_ urlResponse: HTTPURLResponse?) {
            if let urlResponse = urlResponse, let url = urlResponse.url {
                print("\(urlResponse.statusCode) '\(url.absoluteString)'")
            }
        }
    }
}

public typealias CriaLogger = Cria.Logger
public typealias CriaLogLevel = Cria.Logger.Level

