//
//  Cria+Promise.swift
//  Alamofire
//
//  Created by 李二狗 on 2018/5/22.
//

import Foundation
import Oath

public extension Promise {
    
    public func resolveOnMainThread() -> Promise<T> {
        return Promise<T> { resolve, reject, progress in
            self.progress { p in
                DispatchQueue.main.async {
                    progress(p)
                }
            }
            self.registerThen { t in
                DispatchQueue.main.async {
                    resolve(t)
                }
            }
            self.onError { e in
                DispatchQueue.main.async {
                    reject(e)
                }
            }
        }
    }
}
