//
//  Cria.Response.swift
//  Alamofire
//
//  Created by 李二狗 on 2018/5/22.
//

import Foundation

public extension Cria {
    public struct Response {
        public typealias Code = Int
        public typealias HeaderFields = [AnyHashable: Any]
        
        public let code: Cria.Response.Code
        public let headerFields: Cria.Response.HeaderFields
        public let data: Data
        public let destinationURL: URL?
        
        public init(data: Data, code: Cria.Response.Code, header: Cria.Response.HeaderFields) {
            self.data = data
            self.code = code
            self.headerFields = header
            self.destinationURL = nil
        }
        
    }
    
    public struct DownloadResponse {
        public typealias Code = Int
        public typealias HeaderFields = [AnyHashable: Any]
        
        public let code: Cria.Response.Code
        public let headerFields: Cria.Response.HeaderFields
        public let temporaryURL: URL?
        public let destinationURL: URL?
        
        public init(code: Cria.Response.Code, header: Cria.Response.HeaderFields, temporary: URL?, destination: URL?) {
            self.code = code
            self.headerFields = header
            self.destinationURL = destination
            self.temporaryURL = temporary
        }
    }
}

public typealias CriaResponse = Cria.Response
