//
//  GraphQLRequest+Stream.swift
//  NerveLive
//
//  Created by Matthew Chen on 1/1/24.
//

import Foundation
import UIKit
import Amplify

extension GraphQLRequest {
    
    static func queryStreamList() -> GraphQLRequest<JSONValue> {
        let document = """
            query MyQuery {
              listStreams {
                items {
                  id
                  createdAt
                  updatedAt
                  endTime
                }
              }
            }
            """
        return GraphQLRequest<JSONValue>(apiName: "nervelivestream", document: document,
                                         variables: nil,
                                         responseType: JSONValue.self)
    }
}
