//
//  Cria.Request.swift
//  Cria
//
//  Created by Elias Abel on 06/04/16.
//  Copyright © 2016 Meniny Lab. All rights reserved.
//

import Foundation
import Alamofire
import Oath

public extension Cria {
    open class Request {
        
        open var isMultipart: Bool = false
        open var multipartData: [Cria.FormPart] = []
        
        open var baseURL = ""
        open var path = ""
        open var method = Cria.Method.get
        open var params = [String: Any]()
        open var headers = [String: String]()
        open var fullURL: String { return baseURL + path }
        open var timeout: TimeInterval?
        open var logLevels: Cria.Logger.Level {
            get { return logger.logLevels }
            set { logger.logLevels = newValue }
        }
        open var postParameterEncoding: ParameterEncoding = URLEncoding()
        open var showsNetworkActivityIndicator = true
        //    open var errorHandler: ((Jsonify) -> Error?)?
        
        private let logger = Cria.Logger()
        
        fileprivate var req: DataRequest?//Alamofire.Request?
        
        public init() {}
        
        open func cancel() {
            req?.cancel()
        }
        
        func buildRequest() -> URLRequest {
            let url = Foundation.URL(string: fullURL)!
            var r = URLRequest(url: url)
            r.httpMethod = method.rawValue
            for (key, value) in headers {
                r.setValue(value, forHTTPHeaderField: key)
            }
            if let t = timeout {
                r.timeoutInterval = t
            }
            
            var request: URLRequest?
            if method == .post || method == .put {
                request = try? postParameterEncoding.encode(r, with: params)
            } else {
                request = try? URLEncoding.default.encode(r, with: params)
            }
            return request ?? r
        }
        
        /// Returns Promise containing response status code, headers and parsed Jsonify
        open func fetch() -> Promise<Cria.Response> {
            return Promise<Cria.Response> { resolve, reject, progress in
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    if self.showsNetworkActivityIndicator {
                        Cria.NetworkIndicator.shared.startRequest()
                    }
                    if self.isMultipart {
                        self.sendMultipartRequest(resolve, reject: reject, progress: progress)
                    } else {
                        self.sendRequest(resolve, reject: reject, progress: progress)
                    }
                }
            }
        }
        
        func sendMultipartRequest(_ resolve: @escaping (Cria.Response) -> Void,
                                  reject: @escaping (_ error: Error) -> Void,
                                  progress:@escaping (Float) -> Void) {
            upload(multipartFormData: { formData in
                for (key, value) in self.params {
                    let str: String
                    switch value {
                    case let opt as Any?:
                        if let v = opt {
                            str = "\(v)"
                        } else {
                            continue
                        }
                    default:
                        str = "\(value)"
                    }
                    if let data = str.data(using: .utf8) {
                        formData.append(data, withName: key)
                    }
                }
                
                for multipart in self.multipartData {
                    switch multipart.content {
                    case .data(let data):
                        if let filename = multipart.filename, let mime = multipart.mimetype {
                            formData.append(data, withName: multipart.name, fileName: filename, mimeType: mime)
                        } else {
                            if let mime = multipart.mimetype {
                                formData.append(data, withName: multipart.name, mimeType: mime)
                            } else {
                                formData.append(data, withName: multipart.name)
                            }
                        }
                    case .file(let furl):
                        if let filename = multipart.filename, let mime = multipart.mimetype {
                            formData.append(furl, withName: multipart.name, fileName: filename, mimeType: mime)
                        } else {
                            formData.append(furl, withName: multipart.name)
                        }
                    }
                }
            }, with: self.buildRequest(), encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.uploadProgress { p in
                        progress(Float(p.fractionCompleted))
                        }.validate().response(completionHandler: { (response) in
                            self.handleResponse(response, resolve: resolve, reject: reject)
                        })
                case .failure(let error):
                    reject(error)
                }
            })
            logger.logMultipartRequest(self)
        }
        
        func sendRequest(_ resolve: @escaping (Cria.Response) -> Void, reject: @escaping (Error) -> Void,
                         progress:@escaping (Float) -> Void) {
            
            self.req = request(self.buildRequest())
            logger.logRequest(self.req!)
            let bgQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
            req?.validate().downloadProgress(closure: { (p) in
                progress(Float(p.fractionCompleted))
            }).response(queue: bgQueue) { response in
                self.handleResponse(response, resolve: resolve, reject: reject)
            }
        }
        
        func handleResponse(_ response: DefaultDataResponse, resolve: @escaping (Cria.Response) -> Void, reject: @escaping (Error) -> Void) {
            Cria.NetworkIndicator.shared.stopRequest()
            
            self.logger.logResponse(response)
            
            let code = response.response?.statusCode ?? 0
            
            if response.error == nil {
                guard let data = response.data else {
                    reject(CriaError.init(httpStatusCode: code))
                    return
                }
                let header = response.response?.allHeaderFields ?? [:]
                resolve(Cria.Response.init(code: code, headerFields: header, data: data))
            } else {
                reject(response.error ?? CriaError.init(httpStatusCode: code))
            }
        }
    }
}

public typealias CriaRequest = Cria.Request

