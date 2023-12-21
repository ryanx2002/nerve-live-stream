//
//  GraphQLRequest+User.swift
//  NerveLive
//
//  Created by wbx on 2023/12/5.
//

import UIKit
import Amplify

extension GraphQLRequest {
    static func fetchUserProfile(byId id: String) -> GraphQLRequest<JSONValue> {
        let document = """
            query MyQuery($id:ID!) {
              getUser(id:$id) {
                    createdAt
                    deviceToken
                    email
                    firstName
                    id
                    lastName
                    phone
                    profilePhoto
                    updatedAt
                    venmo
                }
            }
            """
        return GraphQLRequest<JSONValue>(apiName: "nervelivestream", document: document,
                                         variables: ["id": id],
                                         responseType: JSONValue.self)
    }

    static func createProfile(subId: String,
                              firstName: String,
                              lastName: String,
                              phone: String) -> GraphQLRequest<JSONValue>{
        let document = """
            mutation MyMutation($FirstName: String, $LastName: String, $Phone: String, $id: ID) {
              createUser(
                input: {id: $id, firstName: $FirstName, lastName: $LastName, phone: $Phone}
              ) {
                venmo
                updatedAt
                profilePhoto
                phone
                lastName
                id
                firstName
                email
                deviceToken
                createdAt
              }
            }
        """
        return GraphQLRequest<JSONValue>(apiName: "nervelivestream", document: document,
                                         variables: ["id": subId,"FirstName":firstName,"LastName":lastName,"Phone": phone],
                                    responseType: JSONValue.self)
    }
    
    static func updateUser(user: User) -> GraphQLRequest<JSONValue>{
        let document = """
            mutation MyMutation($firstName: String, $lastName: String, $phone: String, $id: ID!, $profilePhoto: String, $venmo:String, $deviceToken:String, $email:String, $isMaster:Boolean, $isLive:Boolean) {
              updateUser(
                input: {id: $id, firstName: $firstName, lastName: $lastName, phone: $phone, profilePhoto: $profilePhoto, venmo: $venmo, deviceToken: $deviceToken, email: $email, isMaster: $isMaster, isLive: $isLive}
              ) {
                venmo
                updatedAt
                profilePhoto
                phone
                lastName
                id
                firstName
                email
                deviceToken
                createdAt
                isMaster
                isLive
              }
            }
        """
        return GraphQLRequest<JSONValue>(apiName: "nervelivestream", document: document,
                                         variables: ["id": user.id,
                                                     "firstName":user.firstName ?? "",
                                                     "lastName":user.lastName ?? "",
                                                     "phone": user.phone ?? "",
                                                     "profilePhoto" : user.profilePhoto ?? "",
                                                     "venmo": user.venmo ?? "",
                                                     "deviceToken": user.deviceToken ?? "",
                                                     "email": user.email ?? "",
                                                     "isMaster": user.phone == "+17048901338",
                                                     "isLive" : user.isLive ?? false],
                                    responseType: JSONValue.self)
    }
    
    /// 根据手机号查询用户
    /// - Parameter phone: 手机号码
    static func queryUserList() -> GraphQLRequest<JSONValue> {
        let document = """
            query MyQuery {
              listUsers {
                items {
                  createdAt
                  deviceToken
                  email
                  firstName
                  id
                  lastName
                  phone
                  profilePhoto
                  updatedAt
                  venmo
                }
              }
            }
            """
        return GraphQLRequest<JSONValue>(apiName: "nervelivestream", document: document,
                                         variables: nil,
                                         responseType: JSONValue.self)
    }
}
