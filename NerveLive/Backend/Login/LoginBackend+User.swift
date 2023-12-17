//
//  LoginBackend+User.swift
//  NerveLive
//
//  Created by wbx on 09/12/2023.
//

import Foundation
import Amplify

extension LoginBackend {
    func updateUser(user: User,
                    suc: @escaping () -> Void,
                    fail: @escaping (_ msg:String) -> Void ) {
        Amplify.API.mutate(request: .updateUser(user: user)) {
            event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    guard let postData = try? JSONEncoder().encode(data) else {
                        fail("Failed")
                        return
                    }
                    guard  let d = try? JSONSerialization.jsonObject(with: postData, options: .mutableContainers) else {
                        fail("Failed")
                        return
                    }
                    let dic = d as! NSDictionary
                    if let subDic = dic["updateUser"] as? NSDictionary {
                        print("\(subDic)")
                        LoginTools.sharedTools.saveUserInfo(dic: subDic as! [String : Any])
                        suc();
                    } else {
                        fail("Failed")
                    }
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                    fail("\(error.errorDescription)")
                }
            case .failure(let error):
                print("Got failed event with error \(error)")
                fail("\(error)")
            }
        }
    }
    
    /// 查询用户列表
    func queryUserList(suc: @escaping (_ users: [User]) -> Void,
                     fail: @escaping (_ msg:String) -> Void ) {
        Amplify.API.query(request: .queryUserList()) { event in
            switch event {
            case .success(let result):
                switch result {
                case .success(let data):
                    guard let postData = try? JSONEncoder().encode(data) else {
                        fail("Failed")
                        return
                    }
                    guard  let d = try? JSONSerialization.jsonObject(with: postData, options: .mutableContainers) else {
                        fail("Failed")
                        return
                    }
                    let dic = d as! NSDictionary
                    if let subDic = dic["listUsers"] as? NSDictionary {
                        if let items: NSArray = subDic.object(forKey: "items") as? NSArray {
                            let list = [User].deserialize(from: items) ?? []
                            suc(list)
                        } else {
                            fail("Failed")
                        }
                    } else {
                        fail("Failed")
                    }
                case .failure(let error):
                    print("Got failed result with \(error.errorDescription)")
                    fail("\(error.errorDescription)")
                }
            case .failure(let error):
                fail("\(error)")
            }
        }
    }
    
    /// 根据手机号码查询用户
    func queryUserBy(phone: String,
                     suc: @escaping (_ user: User?) -> Void,
                     fail: @escaping (_ msg:String) -> Void ) {
        queryUserList { users in
            var item: User?
            for user in users {
                if user.phone == phone {
                    item = user
                }
            }
            suc(item)
        } fail: { msg in
            fail(msg)
        }
    }
}
