//
//  Cria.swift
//  Cria
//
//  Created by Elias Abel on 13/11/15.
//  Copyright © 2015 Meniny Lab. All rights reserved.
//

import Alamofire

import Foundation
import Oath

open class Cria {
    
    /**
        Instead of using the same keypath for every call eg: "collection",
        this enables to use a default keypath for parsing collections.
        This is overidden by the per-request keypath if present.
     
     */
    open var defaultCollectionParsingKeyPath: String?
    
    @available(*, unavailable, renamed:"defaultCollectionParsingKeyPath")
    open var jsonParsingColletionKey: String?
    
    /**
        Prints network calls to the console. 
        Values Available are .None, Calls and CallsAndResponses.
        Default is None
    */
    open var logLevels = Cria.Logger.Level.off
    open var postParameterEncoding: ParameterEncoding = URLEncoding()
    
    #if os(iOS)
    /**
        Displays network activity indicator at the top left hand corner of the iPhone's screen in the status bar.
        Is shown by dafeult, set it to false to hide it.
     */
    open var showsNetworkActivityIndicator = true
    #endif
    
    open var baseURL: String
    open var headers: [String: String]
    
    /**
     Create a webservice instance.
     @param Pass the base url of your webservice, E.g : "http://jsonplaceholder.typicode.com"
     
     */
    public init(_ aBaseURL: String, headerFields: [String: String] = [:]) {
        baseURL = aBaseURL
        headers = headerFields
    }
}

