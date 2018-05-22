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
        open var uploadData: Data?
        open var downloadDestination: URL?
        
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
        #if os(iOS)
        open var showsNetworkActivityIndicator = true
        #endif
        
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
        
        /// Returns Promise containing response status code, headers and data
        open func fetch() -> Promise<Cria.Response> {
            return Promise<Cria.Response> { resolve, reject, progress in
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    #if os(iOS)
                    if self.showsNetworkActivityIndicator {
                        Cria.NetworkIndicator.shared.startRequest()
                    }
                    #endif
                    if self.isMultipart {
                        self.sendMultipartRequest(resolve, reject: reject, progress: progress)
                    } else {
                        self.sendRequest(resolve, reject: reject, progress: progress)
                    }
                }
            }
        }
        
        open func upload() -> Promise<Cria.Response> {
            return Promise<Cria.Response> { resolve, reject, progress in
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    #if os(iOS)
                    if self.showsNetworkActivityIndicator {
                        Cria.NetworkIndicator.shared.startRequest()
                    }
                    #endif
                    self.sendDataUploadRequest(resolve, reject: reject, progress: progress)
                }
            }
        }
        
        open func download() -> Promise<Cria.DownloadResponse> {
            return Promise<Cria.DownloadResponse> { resolve, reject, progress in
                DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
                    #if os(iOS)
                    if self.showsNetworkActivityIndicator {
                        Cria.NetworkIndicator.shared.startRequest()
                    }
                    #endif
                    self.sendDownloadRequest(resolve, reject: reject, progress: progress)
                }
            }
        }
        
        func sendDownloadRequest(_ resolve: @escaping (Cria.DownloadResponse) -> Void,
                                 reject: @escaping (_ error: Error) -> Void,
                                 progress:@escaping (Float) -> Void) {
            guard let dest = self.downloadDestination else {
                fatalError("No download destination URL setted")
            }
            let r: DownloadRequest = SessionManager.default.download(self.fullURL, method: self.method.alamofireMethod, parameters: self.params, encoding: URLEncoding(), headers: self.headers, to: { (_, _) -> (URL, DownloadRequest.DownloadOptions) in
                return (dest, [DownloadRequest.DownloadOptions.removePreviousFile, DownloadRequest.DownloadOptions.createIntermediateDirectories])
            })
            r.downloadProgress(queue: .main) { (p) in
                progress(Float(p.fractionCompleted))
                }.validate().response { (response) in
                    self.handleDownloadResponse(response, resolve: resolve, reject: reject)
            }
        }
        
        func sendDataUploadRequest(_ resolve: @escaping (Cria.Response) -> Void,
                               reject: @escaping (_ error: Error) -> Void,
                               progress:@escaping (Float) -> Void) {
            guard let data = self.uploadData else {
                fatalError("No upload data setted")
            }
            let r: UploadRequest = SessionManager.default.upload(data, to: self.fullURL, method: self.method.alamofireMethod, headers: self.headers)
            r.uploadProgress(queue: .main) { (p) in
                progress(Float(p.fractionCompleted))
                }.validate().response { (response) in
                    self.handleResponse(response, resolve: resolve, reject: reject)
            }
        }
        
        func sendMultipartRequest(_ resolve: @escaping (Cria.Response) -> Void,
                                  reject: @escaping (_ error: Error) -> Void,
                                  progress:@escaping (Float) -> Void) {
            SessionManager.default.upload(multipartFormData: { formData in
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
            #if os(iOS)
            Cria.NetworkIndicator.shared.stopRequest()
            #endif
            
            self.logger.logResponse(response)
            
            let code = response.response?.statusCode ?? 0
            
            if response.error == nil {
                guard let data = response.data else {
                    reject(CriaError.init(httpStatusCode: code))
                    return
                }
                let header = response.response?.allHeaderFields ?? [:]
                resolve(Cria.Response.init(data: data, code: code, header: header))
            } else {
                reject(response.error ?? CriaError.init(httpStatusCode: code))
            }
        }
        
        func handleDownloadResponse(_ response: DefaultDownloadResponse, resolve: @escaping (Cria.DownloadResponse) -> Void, reject: @escaping (Error) -> Void) {
            #if os(iOS)
            Cria.NetworkIndicator.shared.stopRequest()
            #endif
            
            self.logger.logDownloadResponse(response)
            
            let code = response.response?.statusCode ?? 0
            
            if response.error == nil {
                let header = response.response?.allHeaderFields ?? [:]
                resolve(Cria.DownloadResponse.init(code: code, header: header, temporary: response.temporaryURL, destination: response.destinationURL))
            } else {
                reject(response.error ?? CriaError.init(httpStatusCode: code))
            }
        }
    }
}

public typealias CriaRequest = Cria.Request

