import SwiftUI

struct ShowCardView: View {
    let show: Show
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Time section
            VStack(alignment: .center) {
                Text(timeString(from: show.airTime))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.secondaryText)
            }
            .frame(width: 50)
            
            // Content section
            VStack(alignment: .leading, spacing: 4) {
                Text(show.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(AppColors.text)
                
                HStack {
                    Text(show.channel)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(show.seasonEpisode)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.secondaryText)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.primary.opacity(0.2))
                        )
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Buttons
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding(8)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
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
    let show = Show(
        title: "风起洛阳",
        posterURL: nil,
        airTime: Date(),
        channel: "优酷",
        description: "唐代洛阳，繁华盛世下隐藏危机",
        seasonEpisode: "S01E15"
    )
    
    return ShowCardView(show: show, onDelete: {})
        .padding()
        .background(AppColors.background)
} 