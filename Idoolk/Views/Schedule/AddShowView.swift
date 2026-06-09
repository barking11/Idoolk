import SwiftUI

struct AddShowView: View {
    let date: Date
    @ObservedObject var viewModel: ScheduleViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var channel: String = ""
    @State private var airTime: Date
    @State private var description: String = ""
    @State private var seasonEpisode: String = ""
    
    // Channels for picker
    let channels = ["优酷", "爱奇艺", "腾讯视频", "bilibili", "芒果TV", "Netflix", "HBO", "其他"]
    
    init(date: Date, viewModel: ScheduleViewModel) {
        self.date = date
        self.viewModel = viewModel
        
        // Set default air time to 8:00 PM on the selected date
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 20
        components.minute = 0
        _airTime = State(initialValue: Calendar.current.date(from: components) ?? date)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Date Display
                        HStack {
                            VStack(alignment: .leading) {
                                Text(formattedDate)
                                    .font(.headline)
                                    .foregroundColor(AppColors.secondaryText)
                                
                                Text("添加追剧提醒")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.text)
                            }
                            Spacer()
                        }
                        .padding(.bottom, 10)
                        
                        // Form Fields
                        VStack(alignment: .leading, spacing: 16) {
                            // Title
                            FormField(title: "剧集名称", systemImage: "tv") {
                                TextField("请输入剧集名称", text: $title)
                                    .foregroundColor(AppColors.text)
                            }
                            
                            // Channel
                            FormField(title: "平台", systemImage: "network") {
                                Picker("选择平台", selection: $channel) {
                                    Text("请选择").tag("")
                                    ForEach(channels, id: \.self) { channel in
                                        Text(channel).tag(channel)
                                    }
                                }
                                .pickerStyle(.menu)
                                .accentColor(AppColors.text)
                            }
                            
                            // Season & Episode
                            FormField(title: "季/集", systemImage: "list.number") {
                                TextField("例如：S01E05", text: $seasonEpisode)
                                    .foregroundColor(AppColors.text)
                            }
                            
                            // Air Time
                            FormField(title: "播出时间", systemImage: "clock") {
                                DatePicker("", selection: $airTime, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .accentColor(AppColors.primary)
                            }
                            
                            // Description
                            FormField(title: "剧集说明", systemImage: "text.alignleft") {
                                TextEditor(text: $description)
                                    .frame(height: 100)
                                    .foregroundColor(AppColors.text)
                                    .background(AppColors.surface)
                                    .cornerRadius(8)
                            }
                        }
                        .padding(.vertical, 10)
                        
                        // Save Button
                        Button(action: saveShow) {
                            Text("保存")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    isFormValid ?
                                    RoundedRectangle(cornerRadius: 12).fill(AppColors.primary) :
                                    RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.5))
                                )
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 20)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(AppColors.text)
                    }
                }
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日 EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && !channel.isEmpty
    }
    
    private func saveShow() {
        let show = Show(
            title: title,
            posterURL: nil,
            airTime: airTime,
            channel: channel,
            description: description,
            seasonEpisode: seasonEpisode.isEmpty ? "未知" : seasonEpisode
        )
        
        viewModel.addShow(for: date, show: show)
        dismiss()
    }
}

struct FormField<Content: View>: View {
    let title: String
    let systemImage: String
    let content: Content
    
    init(title: String, systemImage: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .foregroundColor(AppColors.primary)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.text)
            }
            
            content
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.surface)
                )
        }
    }
}

#Preview {
    AddShowView(date: Date(), viewModel: ScheduleViewModel())
} 
