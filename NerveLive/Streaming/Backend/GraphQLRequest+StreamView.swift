//
//  GraphQLRequest+StreamView.swift
//  NerveLive
//
//  Created by Matthew Chen on 1/3/24.
//

import Foundation
import UIKit
import Amplify

extension GraphQLRequest {
    
    static func queryStreamViewList() -> GraphQLRequest<JSONValue> {
        let document = """
            query MyQuery {
              listStreamViews {
                items {
                  id
                  userId
                  endTime
                  streamId
                  sessions
                  createdAt
                  updatedAt
                }
              }
            }
            """
        return GraphQLRequest<JSONValue>(apiName: "nervelivestream", document: document,
                                         variables: nil,
                                         responseType: JSONValue.self)
    }
}
