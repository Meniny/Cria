//
//  Cria.FormPart.swift
//  Alamofire
//
//  Created by 李二狗 on 2018/5/22.
//

import Foundation
import Alamofire

public extension Cria {
    public struct FormPart: Equatable {
        public enum Content: Equatable {
            case data(Data)
            case file(URL)
        }
        public var content: Cria.FormPart.Content
        public var name: String
        public var filename: String?
        public var mimetype: String?
        
        public init(_ content: Cria.FormPart.Content, name: String, filename: String? = nil, mimetype: String?) {
            self.content = content
            self.name = name
            self.filename = filename
            self.mimetype = mimetype
        }
    }
}

public typealias CriaFormPart = Cria.FormPart
