import Foundation

struct Show: Identifiable, Equatable {
    var id = UUID()
    var title: String
    var posterURL: String?
    var airTime: Date
    var channel: String
    var description: String
    var isFavorite: Bool = false
    var seasonEpisode: String // 例如 "S01E05"
    
    static func ==(lhs: Show, rhs: Show) -> Bool {
        return lhs.id == rhs.id
    }
}

struct DaySchedule: Identifiable {
    var id = UUID()
    var date: Date
    var shows: [Show]
    
    var weekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var monthDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter.string(from: date)
    }
}

class ScheduleViewModel: ObservableObject {
    @Published var weekSchedules: [DaySchedule]
    @Published var currentWeekOffset: Int = 0
    private var allShows: [Show] = []
    
    init() {
        weekSchedules = []

        updateWeekSchedule()
    }
    
    func addShow(for date: Date, show: Show) {
        // Find the day schedule for the given date
        if let index = weekSchedules.firstIndex(where: { isSameDay($0.date, date) }) {
            var daySchedule = weekSchedules[index]
            daySchedule.shows.append(show)
            daySchedule.shows.sort { $0.airTime < $1.airTime }
            weekSchedules[index] = daySchedule
        }
        // Add to overall shows list
        allShows.append(show)
    }
    
    func removeShow(id: UUID) {
        // Remove from current week schedules
        for i in 0..<weekSchedules.count {
            if let index = weekSchedules[i].shows.firstIndex(where: { $0.id == id }) {
                weekSchedules[i].shows.remove(at: index)
            }
        }
        // Remove from all shows
        allShows.removeAll { $0.id == id }
    }
    
    func nextWeek() {
        currentWeekOffset += 1
        updateWeekSchedule()
    }
    
    func previousWeek() {
        currentWeekOffset -= 1
        updateWeekSchedule()
    }
    
    func resetToCurrentWeek() {
        currentWeekOffset = 0
        updateWeekSchedule()
    }
    
    private func updateWeekSchedule() {
        weekSchedules = getWeekDays(weekOffset: currentWeekOffset).map { date in
            let dayShows = allShows.filter { isSameDay($0.airTime, date) }
                .sorted { $0.airTime < $1.airTime }
            return DaySchedule(date: date, shows: dayShows)
        }
    }
    
    private func getWeekDays(weekOffset: Int = 0) -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find the first day of the week (Monday in most locales)
        var weekdayOffset = calendar.component(.weekday, from: today) - calendar.firstWeekday
        if weekdayOffset < 0 {
            weekdayOffset += 7
        }
        
        let startOfWeek = calendar.date(byAdding: .day, value: -weekdayOffset, to: today)!
        let startOfTargetWeek = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startOfWeek)!
        
        var weekDays: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: startOfTargetWeek) {
                weekDays.append(date)
            }
        }
        
        return weekDays
    }
    
    // Helper function to check if two dates are the same day
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    // Load sample data for demo purposes
//    private func loadDemoData() {
//        let calendar = Calendar.current
//        let today = Date()
//        
//        // Demo shows - today
//        let show1 = Show(
//            title: "风起洛阳",
//            posterURL: nil,
//            airTime: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today)!,
//            channel: "优酷",
//            description: "唐代洛阳，繁华盛世下隐藏危机，多方势力暗中角力",
//            seasonEpisode: "S01E15"
//        )
//        
//        let show2 = Show(
//            title: "沉睡花园",
//            posterURL: nil,
//            airTime: calendar.date(bySettingHour: 21, minute: 30, second: 0, of: today)!,
//            channel: "爱奇艺",
//            description: "都市情感剧，讲述职场女性成长故事",
//            seasonEpisode: "S01E08"
//        )
//        
//        // Demo show - tomorrow
//        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
//        let show3 = Show(
//            title: "星际穿越",
//            posterURL: nil,
//            airTime: calendar.date(bySettingHour: 19, minute: 0, second: 0, of: tomorrow)!,
//            channel: "HBO",
//            description: "科幻电影重播，探索宇宙奥秘",
//            seasonEpisode: "电影"
//        )
//        
//        // Demo show - day after tomorrow
//        let dayAfterTomorrow = calendar.date(byAdding: .day, value: 2, to: today)!
//        let show4 = Show(
//            title: "权力的游戏",
//            posterURL: nil,
//            airTime: calendar.date(bySettingHour: 22, minute: 0, second: 0, of: dayAfterTomorrow)!,
//            channel: "腾讯视频",
//            description: "经典史诗奇幻剧重播",
//            seasonEpisode: "S08E04"
//        )
//        
//        // Add all shows to the list
//        allShows = [show1, show2, show3, show4]
//    }
} 
