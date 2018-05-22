//
//  Cria+Calls.swift
//  Cria
//
//  Created by 李二狗 on 2018/5/22.
//

import Foundation
import Oath

// MARK: - Calls
public extension Cria {
    open func call(_ path: String, method: Cria.Method = .get, params: Cria.Params = Cria.Params()) -> Cria.Request {
        let c = defaultCall()
        c.method = method
        c.path = path
        c.params = params
        return c
    }
    
    open func defaultCall() -> Cria.Request {
        let r = Cria.Request()
        r.baseURL = baseURL
        r.logLevels = logLevels
        r.postParameterEncoding = postParameterEncoding
        r.showsNetworkActivityIndicator = showsNetworkActivityIndicator
        r.headers = headers
        return r
    }
    
    public func getRequest(_ path: String, params: Cria.Params = Cria.Params()) -> Cria.Request {
        return call(path, method: .get, params: params)
    }
    
    public func putRequest(_ path: String, params: Cria.Params = Cria.Params()) -> Cria.Request {
        return call(path, method: .put, params: params)
    }
    
    public func postRequest(_ path: String, params: Cria.Params = Cria.Params()) -> Cria.Request {
        return call(path, method: .post, params: params)
    }
    
    public func deleteRequest(_ path: String, params: Cria.Params = Cria.Params()) -> Cria.Request {
        return call(path, method: .delete, params: params)
    }
    
    public func postMultipartRequest(_ path: String,
                                     params: Cria.Params = Cria.Params(),
                                     data: [Cria.FormPart]) -> Cria.Request {
        let c = call(path, method: .post, params: params)
        c.isMultipart = true
        c.multipartData = data
        return c
    }
    
    public func putMultipartRequest(_ path: String,
                                    params: Cria.Params = Cria.Params(),
                                    data: [Cria.FormPart]) -> Cria.Request {
        let c = call(path, method: .put, params: params)
        c.isMultipart = true
        c.multipartData = data
        return c
    }
}

public extension Cria {
    // MARK: - Cria.Response calls
    
    // MARK: Closure
    
    @discardableResult
    open func `do`(_ method: Cria.Method, path: String, params: Cria.Params = Cria.Params(), success: @escaping (Cria.Response) -> Void, progress: @escaping (Float) -> Void = { _ in }, failure: @escaping (Error) -> Void) -> Cria.Request {
        let c = call(path, method: method, params: params)
        let promise: Promise<Cria.Response> = c.fetch().resolveOnMainThread()
        promise.progress(progress).then(success).onError(failure)
        return c
    }
    
    @discardableResult
    open func `do`(_ method: Cria.Method, path: String, params: Cria.Params = Cria.Params(), completion: @escaping (Cria.Response?, Error?) -> Void, progress: @escaping (Float) -> Void = { _ in }) -> Cria.Request {
        let c = call(path, method: method, params: params)
        let promise: Promise<Cria.Response> = c.fetch().resolveOnMainThread()
        promise.progress(progress).then({ r in
            completion(r, nil)
        }).onError({ e in
            completion(nil, e)
        })
        return c
    }
    
    // MARK: Promise
    
    open func `do`(_ method: Cria.Method, path: String, params: Cria.Params = Cria.Params()) -> Promise<Cria.Response> {
        let r = call(path, method: method, params: params)
        return r.fetch().resolveOnMainThread()
    }
    
    open func get(_ path: String, params: Cria.Params = Cria.Params()) -> Promise<Cria.Response> {
        return getRequest(path, params: params).fetch().resolveOnMainThread()
    }
    
    open func post(_ path: String, params: Cria.Params = Cria.Params()) -> Promise<Cria.Response> {
        return postRequest(path, params: params).fetch().resolveOnMainThread()
    }
    
    open func put(_ path: String, params: Cria.Params = Cria.Params()) -> Promise<Cria.Response> {
        return putRequest(path, params: params).fetch().resolveOnMainThread()
    }
    
    open func delete(_ path: String, params: Cria.Params = Cria.Params()) -> Promise<Cria.Response> {
        return deleteRequest(path, params: params).fetch().resolveOnMainThread()
    }
    
    // MARK: - Void calls
    
    open func just(_ method: Cria.Method, path: String, params: Cria.Params = Cria.Params()) -> Promise<Void> {
        let r = call(path, method: method, params: params)
        return r.fetch().registerThen { (_: Cria.Response) -> Void in }.resolveOnMainThread()
    }
    
    // MARK: - Multipart calls
    
    open func postMultipart(_ path: String,
                            params: Cria.Params = Cria.Params(),
                            data: [Cria.FormPart]) -> Promise<Cria.Response> {
        let r = postMultipartRequest(path,
                                     params: params,
                                     data: data)
        return r.fetch().resolveOnMainThread()
    }
    
    open func putMultipart(_ path: String,
                           params: Cria.Params = Cria.Params(),
                           data: [Cria.FormPart]) -> Promise<Cria.Response> {
        let r = putMultipartRequest(path,
                                    params: params,
                                    data: data)
        return r.fetch().resolveOnMainThread()
    }
}

