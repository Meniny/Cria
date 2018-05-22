//
//  Cria.NetworkIndicator.swift
//  Cria
//
//  Created by Elias Abel on 12/11/2016.
//  Copyright © 2016 Meniny Lab. All rights reserved.
//

#if os(iOS)
import Foundation
import UIKit

public extension Cria {
    /**
     Abstracts network activity indicator management.
     - This only shows activity indicator for requests longer than 1 second, the loader is not shown for quick requests.
     - This also waits for 0.2 seconds before hiding the indicator in case other simultaneous requests
     occur in order to avoid flickering.
     
     */
    open class NetworkIndicator: NSObject {
        
        open static let shared = Cria.NetworkIndicator()
        private var runningRequests = 0
        
        open func startRequest() {
            runningRequests += 1
            // For some unowned reason using scheduledTimer does not work in this case.
            let timer = Timer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: false)
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        }
        
        open func stopRequest() {
            runningRequests -= 1
            // For some unowned reason using scheduledTimer does not work in this case.
            let timer = Timer(timeInterval: 0.2, target: self, selector: #selector(tick), userInfo: nil, repeats: false)
            RunLoop.main.add(timer, forMode: RunLoopMode.commonModes)
        }
        
        @objc
        open func tick() {
            let previousValue = UIApplication.shared.isNetworkActivityIndicatorVisible
            let newValue = (runningRequests != 0)
            if newValue != previousValue {
                UIApplication.shared.isNetworkActivityIndicatorVisible = newValue
            }
        }
    }
}

public typealias CriaNetworkIndicator = Cria.NetworkIndicator
#endif
