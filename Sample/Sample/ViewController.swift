//
//  ViewController.swift
//  Sample
//
//  Created by 李二狗 on 2018/5/21.
//  Copyright © 2018年 Meniny Lab. All rights reserved.
//

import UIKit
import Cria
import Oath

class ViewController: UIViewController {
    
    let cria = Cria.init("https://meniny.cn/api/v2/")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        get()
    }
    
    func get() {
        cria.get("posts.json").then { response in
            print("Done: ", response.code)
            }.onError { error in
                print("Error: ", error.localizedDescription)
        }
    }
    
    func common() {
        cria.do(.get, path: "posts.json").then { response in
            print("Done: ", response.code)
            }.onError { error in
                print("Error: ", error.localizedDescription)
        }
    }
    
    func form() {
        let image = #imageLiteral(resourceName: "Cria")
        if let data = UIImageJPEGRepresentation(image, 1) {
            let part = CriaFormPart.init(.data(data), name: "image", mimetype: "image/jpeg")
            cria.postMultipart("some_uploading_api/subpath/", data: [part]).progress { p in
                print("Progress: ", p)
                }.then { response in
                    print("Done: ", response.code)
                }.onError { error in
                    print("Error: ", error.localizedDescription)
            }
        }
    }

}

