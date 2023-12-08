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
                                         variables: ["id": subId,"FirstName":firstName,"LastName":lastName],
                                    responseType: JSONValue.self)
    }
}
