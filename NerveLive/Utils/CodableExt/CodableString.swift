//
//  CodableString.swift
//  Lib_iOS_Codable
//
//  Created by wbx on 2022/11/1.
//

/**
 * 用于解决不知道服务器返回什么类型。。。。都转换为 String 然后保证正常解析
 * 当前支持 Double Int String 其他类型会解析成 nil 或者 ""
 **/

/// 将 String Int Double 解析为 String? 的包装器
@propertyWrapper
public struct PropertyWrapperString: Codable {
    public var wrappedValue: String

    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var value: String = ""

        if let temp = try? container.decode(String.self) {
            value = temp
        } else if let temp = try? container.decode(Int.self) {
            value = String(temp)
        } else if let temp = try? container.decode(Float.self) {
            value = String(temp)
        } else if let temp = try? container.decode(Double.self) {
            value = String(temp)
        } else {
            value = ""
        }

        wrappedValue = value
    }
}

/// 必须重写，否则如果model缺省字段的时候会导致解码失败，找不到key
extension KeyedDecodingContainer {
    func decode( _ type: PropertyWrapperString.Type, forKey key: Key) throws -> PropertyWrapperString {
        try decodeIfPresent(type, forKey: key) ?? PropertyWrapperString(wrappedValue: "")
    }
}

/// encode 相应字段
extension KeyedEncodingContainer {
    mutating func encode(_ value: PropertyWrapperString, forKey key: Key) throws {
        try encodeIfPresent(value.wrappedValue, forKey: key)
    }
}

/*
@propertyWrapper
public class PropertyWrapperClassString: Codable {
    public var wrappedValue: String

    public init(wrappedValue: String) {
        self.wrappedValue = wrappedValue
    }

    required public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        var value: String = ""

        if let temp = try? container.decode(String.self) {
            value = temp
        } else if let temp = try? container.decode(Int.self) {
            value = String(temp)
        } else if let temp = try? container.decode(Float.self) {
            value = String(temp)
        } else if let temp = try? container.decode(Double.self) {
            value = String(temp)
        } else {
            value = ""
        }

        wrappedValue = value
    }
}

extension KeyedDecodingContainer {
    func decode( _ type: PropertyWrapperClassString.Type, forKey key: Key) throws -> PropertyWrapperClassString {
        try decodeIfPresent(type, forKey: key) ?? PropertyWrapperClassString(wrappedValue: "")
    }
}

extension KeyedEncodingContainer {
    mutating func encode(_ value: PropertyWrapperClassString, forKey key: Key) throws {
        try encodeIfPresent(value.wrappedValue, forKey: key)
    }
}
*/
