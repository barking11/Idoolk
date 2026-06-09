import SwiftUI
import Kingfisher

struct SectionListView: View {
    var sectionTitle: String
    var movies: [Movie]
    @Environment(\.presentationMode) var presentationMode
    
    // 网格列布局
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        
        ScrollView {
            
            VStack(spacing: 12) {
                ForEach(movies) { movie in
                    NavigationLink(destination: DetailView(movie: movie)) {
                        MovieCardHorizontal(movie: movie)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, UIHelper.bottomSafeAreaInset + 80)
        }
        .navigationTitle(sectionTitle)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
                                Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
        }
        )
        .navigationBarTitleDisplayMode(.inline)
        
        
        //                ZStack(alignment: .top) {
        //                    // 背景色
        //                    AppColors.background.ignoresSafeArea()
        //
        //                    VStack(spacing: 0) {
        //                        // 导航栏
        //                        HStack {
        //                            Button(action: {
        //                                presentationMode.wrappedValue.dismiss()
        //                            }) {
        //                                Image(systemName: "arrow.left")
        //                                    .font(.system(size: 20, weight: .semibold))
        //                                    .foregroundColor(.white)
        //                            }
        //
        //                            Spacer()
        //
        //                            Text(sectionTitle)
        //                                .font(.system(size: 18, weight: .bold))
        //                                .foregroundColor(.white)
        //
        //                            Spacer()
        //
        //                            // 保持对称性的空按钮
        //                            Image(systemName: "arrow.left")
        //                                .font(.system(size: 20))
        //                                .foregroundColor(.clear)
        //                        }
        //                        .padding(.horizontal)
        //                        .padding(.top, UIHelper.topSafeAreaInset)
        //                        .padding(.bottom, 16)
        //
        //                        // 电影列表
        //                        ScrollView {
        //                            LazyVGrid(columns: columns, spacing: 20) {
        //                                ForEach(movies) { movie in
        //                                    NavigationLink(destination: DetailView(movie: movie)) {
        //                                        MovieListCard(movie: movie)
        //                                    }
        //                                }
        //                            }
        //                            .padding(.horizontal)
        //                            .padding(.top, 8)
        //                            .padding(.bottom, UIHelper.bottomSafeAreaInset + 80)
        //                        }
        //
        //                        Spacer()
        //                    }
        //                }
        //                .navigationBarHidden(true)
    }
}

// 电影列表卡片
struct MovieListCard: View {
    let movie: Movie
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 海报图片
            KFImage(MovieViewModel().getImageURL(path: movie.posterPath))
                .placeholder {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 200)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                .overlay(
                    VStack {
                        Spacer()
                        
                        // 评分信息
                        HStack {
                            HStack(spacing: 4) {
                                Image("rating_star")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                
                                Text(String(format: "%.1f", movie.voteAverage))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(6)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(4)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 8)
                    }
                )
            
            // 电影名称
            Text(movie.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            // 发布时间
            Text(formatDate(movie.firstAirDate))
                .font(.system(size: 12))
                .foregroundColor(AppColors.secondaryText)
                .lineLimit(1)
        }
    }
    
    // 格式化日期
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: dateString) else {
            return dateString
        }
        
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        return dateFormatter.string(from: date)
    }
}
