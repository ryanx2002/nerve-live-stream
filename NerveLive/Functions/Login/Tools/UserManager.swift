//
//  UserManager.swift
//  Boyaios
//
//  Created by huasen on 2020/3/21.
//  Copyright © 2020 yind. All rights reserved.
//

import UIKit
let kUserArchivePathKey = "userInfo.archive"
let key = "userInfo"
class UserManager: NSObject {

    static func saveUerInfo(model: User){
        // 创建文件路径
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("person_data.json") else {
            fatalError("Unable to create file URL.")
        }

        do {
            // 写入数据到文件
            let encoder = JSONEncoder()
            let encodedData = try encoder.encode(model)
            try encodedData.write(to: fileURL)
        } catch {
            print("Failed to write/read data with error: \(error)")
        }
    }
    
    static func readUserInfo() -> User{
        // 创建文件路径
        guard let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("person_data.json") else {
            debugPrint("Unable to create file URL.")
            return User(id: "")
        }

        do {
            // 从文件中读取数据
            let storedData = try? Data(contentsOf: fileURL)
            guard let storedData = storedData else {
                return User(id: "")
            }
            let decoder = JSONDecoder()
            let decodedPerson = try decoder.decode(User.self, from: storedData)
            return decodedPerson
        } catch {
            return User(id: "")
        }
    }
    
    static func clearUserInfo(){
        let model: User = User(id: "")
        UserManager.saveUerInfo(model: model)
    }
}
