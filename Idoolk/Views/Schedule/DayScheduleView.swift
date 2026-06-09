import SwiftUI

struct DayScheduleView: View {
    let daySchedule: DaySchedule
    let isToday: Bool
    @ObservedObject var viewModel: ScheduleViewModel
    @Binding var selectedDate: Date?
    
    var body: some View {
        VStack(spacing: 0) {
            // Date header
            VStack(spacing: 4) {
                Text(daySchedule.weekday)
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(isToday ? AppColors.primary : AppColors.secondaryText)
                
                Text(daySchedule.dayNumber)
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(isToday ? AppColors.primary : AppColors.text)
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isToday ? AppColors.primary.opacity(0.1) : AppColors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(
                                isToday ? AppColors.primary : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
            .padding(.bottom, 8)
            .onTapGesture {
                selectedDate = daySchedule.date
            }
            
            // Shows list
//            if daySchedule.shows.isEmpty {
//                // Empty state
//                VStack(spacing: 12) {
//                    Image(systemName: "tv")
//                        .font(.system(size: 24))
//                        .foregroundColor(AppColors.secondaryText.opacity(0.5))
//                    
//                    Text("没有追剧")
//                        .font(.system(size: 12))
//                        .foregroundColor(AppColors.secondaryText.opacity(0.5))
//                }
//                .frame(maxWidth: .infinity, minHeight: 100)
//                .background(
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 12)
//                            .fill(AppColors.surface.opacity(0.5))
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(AppColors.surface, lineWidth: 1)
//                    }
//                )
//                .onTapGesture {
//                    selectedDate = daySchedule.date
//                }
//            } else {
//                // Shows list
//                VStack(spacing: 8) {
//                    ForEach(daySchedule.shows) { show in
//                        ShowCardMiniView(show: show)
//                            .onTapGesture {
//                                selectedDate = daySchedule.date
//                            }
//                    }
//                }
//            }
        }
        .padding(.horizontal, 4)
    }
}

struct ShowCardMiniView: View {
    let show: Show
    
    var body: some View {
        HStack {
            // Time
            Text(timeString(from: show.airTime))
                .font(.system(size: 12))
                .foregroundColor(AppColors.secondaryText)
                .frame(width: 40, alignment: .leading)
            
            // Title
            Text(show.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.text)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.surface)
        )
    }
    
    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    // Create a sample day schedule
    let calendar = Calendar.current
    let today = Date()
    let show1 = Show(
        title: "风起洛阳",
        posterURL: nil,
        airTime: calendar.date(bySettingHour: 20, minute: 0, second: 0, of: today)!,
        channel: "优酷",
        description: "唐代洛阳",
        seasonEpisode: "S01E15"
    )
    
    let show2 = Show(
        title: "沉睡花园",
        posterURL: nil,
        airTime: calendar.date(bySettingHour: 21, minute: 30, second: 0, of: today)!,
        channel: "爱奇艺",
        description: "都市情感剧",
        seasonEpisode: "S01E08"
    )
    
    let daySchedule = DaySchedule(date: today, shows: [show1, show2])
    let viewModel = ScheduleViewModel()
    
    return HStack {
        DayScheduleView(
            daySchedule: daySchedule,
            isToday: true,
            viewModel: viewModel,
            selectedDate: .constant(nil)
        )
        
        DayScheduleView(
            daySchedule: DaySchedule(date: today, shows: []),
            isToday: false,
            viewModel: viewModel,
            selectedDate: .constant(nil)
        )
    }
    .padding()
    .background(AppColors.background)
} 
