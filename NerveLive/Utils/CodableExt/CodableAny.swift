//
//  CodableAny.swift
//  Lib_iOS_Codable
//
//  Created by wbx on 2022/11/28.
//

import Foundation

/**
 * 给Any封装一个支持Codable的类型
 */

/// 支持Any的Codable
public struct AnyCodable: Decodable {

    /// AnyCodable 对应的原始值，可能为Any、[String: Any]
    public var rawValue: Any

    struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
        init?(stringValue: String) { self.stringValue = stringValue }
    }

    init(value: Any) {
        self.rawValue = value
    }

    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            var result = [String: Any]()
            try container.allKeys.forEach { (key) throws in
                result[key.stringValue] = try container.decode(AnyCodable.self, forKey: key).rawValue
            }
            rawValue = result
        } else if var container = try? decoder.unkeyedContainer() {
            var result = [Any]()
            while !container.isAtEnd {
                result.append(try container.decode(AnyCodable.self).rawValue)
            }
            rawValue = result
        } else if let container = try? decoder.singleValueContainer() {
            if let intVal = try? container.decode(Int.self) {
                rawValue = intVal
            } else if let doubleVal = try? container.decode(Double.self) {
                rawValue = doubleVal
            } else if let boolVal = try? container.decode(Bool.self) {
                rawValue = boolVal
            } else if let stringVal = try? container.decode(String.self) {
                rawValue = stringVal
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing serialisable")
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not serialise"))
        }
    }
}

extension AnyCodable: Encodable {
    public func encode(to encoder: Encoder) throws {
        if let array = rawValue as? [Any] {
            var container = encoder.unkeyedContainer()
            for value in array {
                let decodable = AnyCodable(value: value)
                try container.encode(decodable)
            }
        } else if let dictionary = rawValue as? [String: Any] {
            var container = encoder.container(keyedBy: CodingKeys.self)
            for (key, value) in dictionary {
                let codingKey = CodingKeys(stringValue: key)!
                let decodable = AnyCodable(value: value)
                try container.encode(decodable, forKey: codingKey)
            }
        } else {
            var container = encoder.singleValueContainer()
            if let intVal = rawValue as? Int {
                try container.encode(intVal)
            } else if let doubleVal = rawValue as? Double {
                try container.encode(doubleVal)
            } else if let boolVal = rawValue as? Bool {
                try container.encode(boolVal)
            } else if let stringVal = rawValue as? String {
                try container.encode(stringVal)
            } else {
                throw EncodingError.invalidValue(rawValue, EncodingError.Context.init(codingPath: [], debugDescription: "The value is not encodable"))
            }
        }
    }
}
