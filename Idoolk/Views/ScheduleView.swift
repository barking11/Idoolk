//
//  ScheduleView.swift
//  Idoolk
//
//  Created by wang k on 2025/3/27.
//

import SwiftUI

struct ScheduleView: View {
    @StateObject private var viewModel = ScheduleViewModel()
    @State private var selectedDate: Date? = nil
    @State private var showingAddSheet = false
    @State private var showingShowDetail = false
    @State private var selectedShow: Show? = nil
    
    // For detecting swipe gestures
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Week header with navigation controls
                    weekHeader
                    
                    // Weekly scroll view
                    weeklyScrollView
                    
                    // Selected day detailed view
                    if let selectedDate = selectedDate {
                        selectedDayView(for: selectedDate)
                    } else {
                        // Today's shows when no day is selected
                        todaysShowsView
                    }
                }
                .padding(.horizontal)
                .sheet(isPresented: $showingAddSheet) {
                    if let date = selectedDate {
                        AddShowView(date: date, viewModel: viewModel)
                    }
                }
            }
            .navigationTitle("追剧提醒")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        viewModel.resetToCurrentWeek()
                        selectedDate = nil
                    }) {
                        Image("back_to_today")
                            .foregroundColor(AppColors.text)
                    }
                }
            }
        }
    }
    
    // MARK: - Components
    
    private var weekHeader: some View {
        HStack {
            Button(action: {
                withAnimation {
                    viewModel.previousWeek()
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(AppColors.text)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(AppColors.surface)
                    )
            }
            
            Spacer()
            
            // Week indicator
            VStack {
                Text(weekDateRangeText)
                    .font(.subheadline)
                    .foregroundColor(AppColors.secondaryText)
                
                if viewModel.currentWeekOffset == 0 {
                    Text("本周")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(AppColors.primary.opacity(0.2))
                        )
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    viewModel.nextWeek()
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.text)
                    .padding(8)
                    .background(
                        Circle()
                            .fill(AppColors.surface)
                    )
            }
        }
        .padding(.vertical, 8)
    }
    
    private var weeklyScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.weekSchedules) { daySchedule in
                    DayScheduleView(
                        daySchedule: daySchedule,
                        isToday: isSameDay(daySchedule.date, Date()),
                        viewModel: viewModel,
                        selectedDate: $selectedDate
                    )
                    .frame(width: UIScreen.main.bounds.width / 4.5)
                }
            }
            .padding(.vertical, 8)
        }
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width < -threshold {
                        withAnimation {
                            viewModel.nextWeek()
                        }
                    } else if value.translation.width > threshold {
                        withAnimation {
                            viewModel.previousWeek()
                        }
                    }
                }
        )
    }
    
    private func selectedDayView(for date: Date) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header for selected day
            HStack {
                VStack(alignment: .leading) {
                    Text(formattedSelectedDate(date))
                        .font(.headline)
                        .foregroundColor(AppColors.text)
                    
                    Text(showCountText(for: date))
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText)
                }
                
                Spacer()
                
                Button(action: {
                    showingAddSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("添加")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(AppColors.primary)
                    )
                }
            }
            
            // Shows list for selected day
            ScrollView {
                LazyVStack(spacing: 12) {
                    if let daySchedule = viewModel.weekSchedules.first(where: { isSameDay($0.date, date) }) {
                        if daySchedule.shows.isEmpty {
                            VStack(spacing: 16) {
                                Image("no_data")
                                    .foregroundColor(AppColors.secondaryText.opacity(0.5))
                                
                                Text("当日没有追剧安排")
                                    .font(.headline)
                                    .foregroundColor(AppColors.secondaryText)
                                
                                Button(action: {
                                    showingAddSheet = true
                                }) {
                                    Text("添加追剧提醒")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(AppColors.primary)
                                        )
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(daySchedule.shows) { show in
                                ShowCardView(show: show) {
                                    // Delete action
                                    viewModel.removeShow(id: show.id)
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    private var todaysShowsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("今日追剧")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                
                Spacer()
                
                Button(action: {
                    selectedDate = Date()
                    showingAddSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("添加")
                    }
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(AppColors.primary)
                    )
                }
            }
            
            // Today's shows
            ScrollView {
                LazyVStack(spacing: 12) {
                    if let today = viewModel.weekSchedules.first(where: { isSameDay($0.date, Date()) }) {
                        if today.shows.isEmpty {
                            VStack(spacing: 16) {
                                Image("no_data")
                                    .foregroundColor(AppColors.secondaryText.opacity(0.5))
                                
                                Text("今日没有追剧安排")
                                    .font(.headline)
                                    .foregroundColor(AppColors.secondaryText)
                                
                                Button(action: {
                                    selectedDate = Date()
                                    showingAddSheet = true
                                }) {
                                    Text("添加追剧提醒")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(AppColors.primary)
                                        )
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            ForEach(today.shows) { show in
                                ShowCardView(show: show) {
                                    // Delete action
                                    viewModel.removeShow(id: show.id)
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    // MARK: - Helper methods
    
    private var weekDateRangeText: String {
        guard let firstDay = viewModel.weekSchedules.first?.date,
              let lastDay = viewModel.weekSchedules.last?.date else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        
        return "\(formatter.string(from: firstDay)) - \(formatter.string(from: lastDay))"
    }
    
    private func formattedSelectedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func showCountText(for date: Date) -> String {
        guard let daySchedule = viewModel.weekSchedules.first(where: { isSameDay($0.date, date) }) else {
            return "暂无追剧安排"
        }
        
        let count = daySchedule.shows.count
        
        switch count {
        case 0:
            return "暂无追剧安排"
        case 1:
            return "1个追剧提醒"
        default:
            return "\(count)个追剧提醒"
        }
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(date1, inSameDayAs: date2)
    }
}

#Preview {
    ScheduleView()
}
