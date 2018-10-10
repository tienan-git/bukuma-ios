//
//  NSDate+Extension.swift
//  Bukuma_ios_swift
//
//  Created by 千葉大志 on 2016/05/06.
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

public extension NSDate {
    
    static func AZ_currentCalendar() ->NSCalendar {
        let dictionary = Thread.current.threadDictionary
        var currentCalendar: NSCalendar? = dictionary.object(forKey: "AZ_currentCalendar") as? NSCalendar
        if currentCalendar == nil {
            currentCalendar = Calendar.current as NSCalendar?
            dictionary.setObject(currentCalendar!, forKey: "AZ_currentCalendar" as NSCopying)
        }
        return currentCalendar!
    }
//
    public func chatDateString() ->String {
        return self.isToday() ? self.chatDateTodayWithDate() : self.chatDateWithDate()
    }
    
    public func chatDateTodayWithDate() ->String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self as Date)
    }

    public func chatDateWithDate() ->String {
        let gap: Int = self.daysAfterDate(date: Date() as NSDate)
        if gap < 7 {
            return self.showWeekDays(dayGap: -gap)
        }
        
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "MM:dd"
        return formatter.string(from: self as Date)
    }
    
    func chatDate() ->String {
        let day =  "\((self as Date).month)/\((self as Date).day) "
        
        let jstToday = Timepiece.Date.today().addingTimeInterval(60 * 60 * 9)
        let jstSelf = (self as Date).addingTimeInterval(60 * 60 * 9)
        
        let gap: Int = jstSelf.daysAfterDate(jstToday) //    self.daysAfterDate(date: jstToday as NSDate)
        
        if self.isToday() {
            return "今日"
        }
        
        if self.isYesterDay() {
            return "昨日"
        }
        
        var weekday: String = ""
        if gap < 7 {
            weekday = self.showWeekDays(dayGap: -gap)
        }
        
        return "\(day)(\(weekday))"

    }

    public func minutesBeforeDate(date: NSDate) ->Int {
        let timeIntervalSinceDate: TimeInterval = date.timeIntervalSince(self as Date)
        return Int(timeIntervalSinceDate / 60)
    }
    
    public func hoursAfterDate(date: NSDate) ->Int {
        let timeIntervalSinceDate: TimeInterval = self.timeIntervalSince(date as Date)
        return Int(timeIntervalSinceDate / (60 * 60))
    }
    
    public func hoursBeforeDate(date: NSDate) ->Int {
        let timeIntervalSinceDate: TimeInterval = date.timeIntervalSince(self as Date)
        return Int(timeIntervalSinceDate / (60 * 60))
    }
    
    public func daysAfterDate(date: NSDate) ->Int {
        let timeIntervalSinceDate: TimeInterval = self.timeIntervalSince(date as Date)
        return Int(timeIntervalSinceDate / (24 * 60 * 60))
    }
    
    public func daysBeforeDate(date: NSDate) ->Int {
        let timeIntervalSinceDate: TimeInterval = date.timeIntervalSince(self as Date)
        return Int(timeIntervalSinceDate / (24 * 60 * 60))
    }
    
    public func dateByAddingMinutes(dMinutes: Double) ->NSDate {
        let components: NSDateComponents = NSDateComponents()
        components.minute = Int(dMinutes)
        let calendar: NSCalendar = NSDate.AZ_currentCalendar() as NSCalendar
        return calendar.date(byAdding: components as DateComponents, to: self as Date, options:  NSCalendar.Options(rawValue: 0))! as NSDate
    }
    
    public func dateByAddingDays(dDays: Int) ->NSDate {
        let components: NSDateComponents = NSDateComponents()
        components.day = dDays
        let calendar: NSCalendar = NSDate.AZ_currentCalendar() as NSCalendar
        return calendar.date(byAdding: components as DateComponents, to: self as Date, options:  NSCalendar.Options(rawValue: 0))! as NSDate
    }
    
    private func showWeekDays(dayGap: Int) -> String {
        
        if (self as Date).weekday - 1 > weekArrayJ.count {
            return ""
        }
        
        return weekArrayJ[(self as Date).weekday - 1]
    }
    
    private func weekDays(dayGap: Int) -> String {
        if (self as Date).weekday - 1 > weekArrayJ.count {
            return ""
        }
        
        return weekArrayJ[(self as Date).weekday - 1]
    }
    
    public func longDateTextWithDate() -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: self as Date)
    }
    
    public func isEqualToDateIgnoringTime(otherDate: NSDate) ->Bool {
        return (self as Date).year == (otherDate as Date).year && (self as Date).month == (otherDate as Date).month && (self as Date).day == (otherDate as Date).day
    }
    
    func isToday() ->Bool {
        let jstToday = Timepiece.Date.today().addingTimeInterval(60 * 60 * 9)
        let jstSelf = (self as Date).addingTimeInterval(60 * 60 * 9)
        return jstSelf.timeIntervalSinceNow - jstToday.timeIntervalSinceNow < 60 * 60 * 24 && jstSelf.timeIntervalSinceNow - jstToday.timeIntervalSinceNow > 0
    }
    
    func isYesterDay() ->Bool {
        let jstToday = Timepiece.Date.today().addingTimeInterval(60 * 60 * 9)
        let jstSelf = (self as Date).addingTimeInterval(60 * 60 * 9)
        let gap = jstSelf.timeIntervalSinceNow - jstToday.timeIntervalSinceNow
        return gap > -60 * 60 * 24 && gap < 0
    }
    
}
