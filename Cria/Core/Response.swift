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
    }
}

public typealias CriaResponse = Cria.Response
