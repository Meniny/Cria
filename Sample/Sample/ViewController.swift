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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    let cria = Cria.init("https://meniny.cn/api/v2/")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.backgroundColor = UIColor.clear
        self.imageView.contentMode = .scaleAspectFit
        self.textView.text = ""
        self.textView.font = UIFont.systemFont(ofSize: 14)
        
        get()
        download()
    }
    
    func join(_ items: Any..., f: String = #function) {
        let string = items.map({ "\($0)" }).joined()
        if !self.textView.text.isEmpty {
            self.textView.text = self.textView.text + "\n【" + f + "】\n" +  string
        } else {
            self.textView.text = "【" + f + "】\n" + string
        }
    }
    
    func get() {
        cria.get("portfolio_paintings.json").then { response in
            self.join("Done: ", response.code)
            }.onError { error in
                self.join("Error: ", error.localizedDescription)
        }
    }
    
    func common() {
        cria.do(.get, path: "posts.json").then { response in
            self.join("Done: ", response.code)
            }.onError { error in
                self.join("Error: ", error.localizedDescription)
        }
    }
    
    func form() {
        let image = #imageLiteral(resourceName: "Cria")
        if let data = UIImageJPEGRepresentation(image, 1) {
            let part = CriaFormPart.init(.data(data), name: "image", mimetype: "image/jpeg")
            cria.postMultipart("some_uploading_api/subpath/", data: [part]).progress { p in
                self.join("Progress: ", p)
                }.then { response in
                    self.join("Done: ", response.code)
                }.onError { error in
                    self.join("Error: ", error.localizedDescription)
            }
        }
    }
    
    let downloader = Cria.init("https://meniny.cn/assets/images/")
    
    func download() {
        downloader.download("app_banner.png", to: URL.init(fileURLWithPath: "/Users/elias/Desktop/0_cria.png")).progress { p in
            self.join("Progress: ", p)
            }.then { response in
                self.join("Done: ", response.destinationURL?.path ?? "nil")
                if let url = response.destinationURL, let image = UIImage.init(contentsOfFile: url.path) {
                    self.join("Image: ", image)
                    self.imageView.image = image
                } else {
                    self.join("Image: Cannot read.")
                }
            }.onError { error in
                self.join("Error: ", error.localizedDescription)
        }
    }

}

