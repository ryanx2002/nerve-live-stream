//
//  ImageCacheUtils.swift
//  Mike
//
//  Created by 殷聃 on 2021/5/11.
//

import UIKit
import Amplify
class ImageCacheUtils: NSObject {
    static let sharedTools = ImageCacheUtils()
    let userDefault = UserDefaults.standard
    private override init() {
        super.init()
    }
    func imageUrl(key:String?,imgUrlCompletion:@escaping (_ img:String?,_ urlIsNull:Bool)->Void){
        if StringUtils.isBlank(value: key) {
            imgUrlCompletion("",true)
        }else{
//            guard let imageUrl = self.userDefault.object(forKey: key!) else{
//                Amplify.Storage.getURL(key: key!) { event in
//                    switch event {
//                    case let .success(url):
//                        print("Completed: \(url)")
//                        self.userDefault.setValue(url.absoluteString, forKey: key!)
//                        self.userDefault.synchronize()
//                        imgUrlCompletion("\(url)",false)
//                    case let .failure(storageError):
//                        print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
//                        imgUrlCompletion("",true)
//                    }
//                }
//                return
//            }
//            guard let imgUrl = imageUrl as? String else{
//                imgUrlCompletion("",true)
//                return
//            }
//            if StringUtils.isBlank(value: imgUrl) {
//                imgUrlCompletion("",true)
//            }else{
//                imgUrlCompletion(imgUrl,false)
//            }
            Amplify.Storage.getURL(key: key!) { event in
                switch event {
                case let .success(url):
//                    print("Completed: \(url)")
                    self.userDefault.setValue(url.absoluteString, forKey: key!)
                    self.userDefault.synchronize()
                    DispatchQueue.main.async {
                        imgUrlCompletion("\(url)",false)
                    }
                case let .failure(storageError):
                    print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                    DispatchQueue.main.async {
                        imgUrlCompletion("",true)
                    }
                }
            }
        }
        
    }
    func clearAllUserDefaultsData(){
       let userDefaults = UserDefaults.standard
       let dics = userDefaults.dictionaryRepresentation()
       for key in dics {
           userDefaults.removeObject(forKey: key.key)
       }
       userDefaults.synchronize()
    }
}
