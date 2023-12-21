//
//  Date+Ext.swift
//  Nerve
//
//  Created by wbx on 2023/10/7.
//

import Foundation

extension Date {
    /// 获取最近的时间格式 刚刚/分钟前/小时前/天前/...
    /// - Parameter time: 时间
    /// - Returns: 字符串
    static func getLatestTime(time: Date?) -> String {
        let now: Date = Date() // 当前时间
        let interval: Int = Int(max(0, now.timeIntervalSince1970 - (time ?? Date()).timeIntervalSince1970))
        var time: String = ""
        if interval < 60 {
            time = "\(interval)s"
        } else if interval < 60*60 {
            if interval / 60 <= 0 {
                time = "\(interval)s"
            } else {
                time = "\(interval / 60)m ago"
            }
        } else if interval < 60 * 60 * 24 {
            time = "\(interval / (60 * 60))h"
        } else {
            time = "\(interval / (60 * 60 * 24))d"
        }
        return time
    }
    
    static func getFormatDate(time:Date?) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
//        let date = Date() // 这里使用你要格式化的日期
        let formattedDate = dateFormatter.string(from: time ?? Date())
        return formattedDate
    }
    
    static func getWeekForNow() -> Int{
        // 获取当前日期
        let currentDate = Date()

        // 创建一个日历对象
        let calendar = Calendar.current

        // 获取当前日期对应的星期几（返回值是 1 表示周日，2 表示周一，以此类推）
        let weekday = calendar.component(.weekday, from: currentDate)
        return weekday-1
    }
 }
