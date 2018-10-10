//
//  Date.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/10/26.
//  Copyright © 2016年 Hiroshi Chiba. All rights reserved.
//

import Timepiece

private let weekArrayJ: [String] = ["日曜日","月曜日","火曜日","水曜日","木曜日","金曜日","土曜日"]
private let weekArrayEn: [String] = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
private let SECONDS_IN_MINUTE: Double = 60
private let MINUTES_IN_HOUR: Double = 60
private let DAYS_IN_WEEK: Double = 60
private let SECONDS_IN_HOUR: Double = SECONDS_IN_MINUTE * MINUTES_IN_HOUR
private let HOURS_IN_DAY: Double = 24
private let SECONDS_IN_DAY: Double = HOURS_IN_DAY * SECONDS_IN_HOUR

public extension Date {
    
    static func AZ_currentCalendar() ->Calendar {
        let dictionary = Thread.current.threadDictionary
        var currentCalendar: Calendar? = dictionary.object(forKey: "AZ_currentCalendar") as? Calendar
        if currentCalendar == nil {
            currentCalendar = Calendar.current
            dictionary.setObject(currentCalendar!, forKey: "AZ_currentCalendar" as NSCopying)
        }
        return currentCalendar!
    }
    
    public func isToday() ->Bool {
        return self.isToday()
    }
    
    public func chatDateString() ->String {
        return self.isToday() ? self.chatDateTodayWithDate() : self.chatDateWithDate()
    }
    
    public func chatDateTodayWithDate() ->String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    public func chatDateWithDate() ->String {
        let gap: Int = self.daysAfterDate(Date())
        if gap < 7 {
            return self.showWeekDays(-gap)
        }
        
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "MM:dd"
        return formatter.string(from: self as Date)
    }
    
    func chatDate() ->String {
        let day =  "\(self.month)/\(self.day) "
        let gap: Int = self.daysAfterDate(Date())
        
        var weekday: String = ""
        if gap < 7 {
           weekday = self.showWeekDays(-gap)
        }
        return "\(day)(\(weekday))"
    }
    
    public func minutesAfterDate(_ date: Date) ->Int {
        let timeIntervalSinceDate: TimeInterval = self.timeIntervalSince(date)
        return Int(timeIntervalSinceDate / 60)
    }
    
    public func minutesBeforeDate(_ date: Date) ->Int {
        let timeIntervalSinceDate: TimeInterval = date.timeIntervalSince(self)
        return Int(timeIntervalSinceDate / 60)
    }
    
    public func hoursAfterDate(_ date: Date) ->Int {
        let timeIntervalSinceDate: TimeInterval = self.timeIntervalSince(date)
        return Int(timeIntervalSinceDate / (60 * 60))
    }
    
    public func hoursBeforeDate(_ date: Date) ->Int {
        let timeIntervalSinceDate: TimeInterval = date.timeIntervalSince(self)
        return Int(timeIntervalSinceDate / (60 * 60))
    }
    
    public func daysAfterDate(_ date: Date) ->Int {
        let timeIntervalSinceDate: TimeInterval = self.timeIntervalSince(date)
        return Int(timeIntervalSinceDate / (24 * 60 * 60))
    }
    
    public func daysBeforeDate(_ date: Date) ->Int {
        let timeIntervalSinceDate: TimeInterval = date.timeIntervalSince(self)
        return Int(timeIntervalSinceDate / (24 * 60 * 60))
    }
    
    public func dateByAddingMinutes(_ dMinutes: Double) ->Date {
        return self.addingTimeInterval((SECONDS_IN_MINUTE * dMinutes))
    }
    
    public func dateByAddingDays(_ dDays: Int) ->Date {
        var components: DateComponents = DateComponents()
        components.day = dDays
        let calendar: Calendar = Date.AZ_currentCalendar()
        return calendar.date(byAdding: components, to: self) ?? Date()
    }
    
    fileprivate func showWeekDays(_ dayGap: Int) -> String {
        if dayGap == 0 {
            return "今日"
        }
        if dayGap == 1 {
            return "昨日"
        }
        
        if self.weekday - 1 > weekArrayJ.count {
            return ""
        }
        
        return weekArrayJ[self.weekday - 1]
    }
    
    public func longDateTextWithDate() -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    public func isEqualToDateIgnoringTime(_ otherDate: Date) ->Bool {
        return self.year == otherDate.year && self.month == otherDate.month && self.day == otherDate.day
    }
    
    public func string(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
