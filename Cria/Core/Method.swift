//
//  Cria.Method.swift
//  Cria
//
//  Created by Elias Abel on 06/04/16.
//  Copyright © 2016 Meniny Lab. All rights reserved.
//

import Foundation
import Alamofire

public extension Cria {
    public enum Method: String, Equatable {
        case options = "OPTIONS"
        case get     = "GET"
        case head    = "HEAD"
        case post    = "POST"
        case put     = "PUT"
        case patch   = "PATCH"
        case delete  = "DELETE"
        case trace   = "TRACE"
        case connect = "CONNECT"
        
        public var alamofireMethod: HTTPMethod {
            return HTTPMethod.init(rawValue: self.rawValue) ?? .get
        }
    }
}

public typealias CriaMethod = Cria.Method
