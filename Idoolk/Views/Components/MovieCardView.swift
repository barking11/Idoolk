import SwiftUI
import Kingfisher

// 电影卡片 - 常规样式（用于奇数行分区）
struct MovieCardRegular: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 封面图
            KFImage(MovieViewModel().getImageURL(path: movie.posterPath))
                .placeholder {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // 标题
            Text(movie.name)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColors.text)
                .lineLimit(1)
            
            HStack(spacing: 6) {
                // 评分
                HStack(spacing: 2) {
                    Image("rating_star")
                        .resizable()
                        .frame(width: 15, height: 15)
                    
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(AppColors.text)
                }
                
                Text("·")
                    .foregroundColor(AppColors.secondaryText)
                
                // 类型标签
                if let firstGenre = movie.genreIds.first, let genreText = MovieSection.genreMap[firstGenre] {
                    Text(genreText)
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.secondaryText)
                }
            }
        }
        .frame(width: 130)
    }
}

// 电影卡片 - 水平样式（用于偶数行分区）
struct MovieCardHorizontal: View {
    let movie: Movie
    
    var body: some View {
        HStack(spacing: 12) {
            // 封面图
            KFImage(MovieViewModel().getImageURL(path: movie.posterPath))
                .placeholder {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.gray)
                        )
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // 内容
            VStack(alignment: .leading, spacing: 10) {
                Text(movie.name)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(AppColors.text)
                    .lineLimit(1)
                    .padding(.top, 5)
                
                HStack(spacing: 4) {
                    Image("rating_star")
                        .resizable()
                        .frame(width: 15, height: 15)
                    
                    Text(String(format: "%.1f", movie.voteAverage))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColors.text)
                }
                
                // 类型标签
                HStack(spacing: 4) {
                    ForEach(movie.genreIds.prefix(2), id: \.self) { genreId in
                        if let genreText = MovieSection.genreMap[genreId] {
                            Text(genreText)
                                .font(.system(size: 12))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(AppColors.surface)
                                )
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
                
                Spacer()
                
                // 首播日期
                Text("首播: \(movie.firstAirDate)")
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.secondaryText)
                    .padding(.bottom, 5)
            }
            .frame(height: 150, alignment: .leading)
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.surface.opacity(0.5))
        )
    }
}

// 电影卡片 - 大型样式（用于特别推荐区域）
struct MovieCardFeatured: View {
    let movie: Movie
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 背景图
            KFImage(MovieViewModel().getImageURL(path: movie.backdropPath, size: "w780"))
                .placeholder {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // 渐变蒙版
            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.7), Color.black.opacity(0)]),
                startPoint: .bottom,
                endPoint: .center
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // 内容
            VStack(alignment: .leading, spacing: 8) {
                Text(movie.name)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                
                HStack(spacing: 8) {
                    // 评分
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                        
                        Text(String(format: "%.1f", movie.voteAverage))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Text("·")
                        .foregroundColor(.white.opacity(0.7))
                    
                    // 类型标签
                    Text(MovieSection.getGenreString(for: movie.genreIds))
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // 播放按钮
                Button(action: {}) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("立即观看")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(AppColors.primary)
                    )
                }
                .padding(.top, 8)
            }
            .padding(20)
        }
    }
}

