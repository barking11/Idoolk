import SwiftUI
import Kingfisher
import Combine
//
//struct MovieSectionHeader: View {
//    let title: String
//
//    var body: some View {
//        HStack {
//            Text(title)
//                .font(.system(size: 20, weight: .bold))
//                .foregroundColor(AppColors.text)
//
//            Spacer()
//
//            Button(action: {}) {
//                HStack(spacing: 4) {
//                    Text("查看更多")
//                        .font(.system(size: 14))
//
//                    Image(systemName: "chevron.right")
//                        .font(.system(size: 12))
//                }
//                .foregroundColor(AppColors.primary)
//            }
//        }
//        .padding(.horizontal)
//        .padding(.top, 16)
//        .padding(.bottom, 8)
//    }
//}
//
//// 奇数行分区 - 水平滚动卡片
//struct MovieSectionRegular: View {
//    let section: MovieSection
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            MovieSectionHeader(title: section.title)
//
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 16) {
//                    ForEach(section.movies, id: \.id) { movie in
//                        MovieCardRegular(movie: movie)
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.vertical, 8)
//            }
//        }
//    }
//}
//
//// 偶数行分区 - 垂直列表
//struct MovieSectionList: View {
//    let section: MovieSection
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            MovieSectionHeader(title: section.title)
//
//            VStack(spacing: 12) {
//                ForEach(section.movies.prefix(3), id: \.id) { movie in
//                    MovieCardHorizontal(movie: movie)
//                }
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 8)
//        }
//    }
//}
//
//// 特别推荐区
struct MovieSectionFeatured: View {
    let section: MovieSection
    @State private var currentTab = 0
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 5, on: .main, in: .common)
    @State private var timerCancellable: Cancellable? = nil
    
    // 存储取消器的集合
    @State private var setupCancellables = Set<AnyCancellable>()
    @State private var apiResponse: HomeResponse? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TabView(selection: $currentTab) {
                ForEach(Array(zip(section.movies.indices, section.movies)), id: \.0) { index, movie in
                    NavigationLink(destination: DetailView(movie: movie)) {
                        ZStack(alignment: .bottomLeading) {
                            // 背景图片
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
                                .frame(width: UIScreen.main.bounds.size.width, height: 400)
                                .clipped()
                            
                            // 渐变遮罩
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)]),
                                startPoint: .bottom,
                                endPoint: .top
                            )
                            .frame(height: 400)
                            
                            LinearGradient(
                                gradient: Gradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0)]),
                                startPoint: .bottom,
                                endPoint: .center
                            )
                            .frame(height: 400)
                            
                            // 内容信息
                            VStack(alignment: .leading, spacing: 8) {
                                // 标题
                                Text(movie.name)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
                                
                                // 评分和类型
                                HStack(spacing: 8) {
                                    HStack(spacing: 4) {
                                        Image("rating_star")
                                            .resizable()
                                            .frame(width: 15, height: 15)
                                        
                                        Text(String(format: "%.1f", movie.voteAverage))
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text("·")
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text(MovieSection.getGenreString(for: movie.genreIds))
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                // 用户评论替代简介
                                HStack(alignment: .top, spacing: 8) {
                                    // 大引号
                                    Text("“")
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(AppColors.primary.opacity(0.7))
                                        .offset(y: -8)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        // 从API获取的评论内容或者显示概述
                                        Text(getReviewContent(for: movie) ?? movie.overview)
                                            .font(.system(size: 14))
                                            .foregroundColor(.white.opacity(0.9))
                                            .lineLimit(2)
                                        
                                        // 用户昵称
                                        if let reviewName = getReviewName(for: movie) {
                                            HStack {
                                                Spacer()
                                                
                                                Text("—— \(reviewName)")
                                                    .font(.system(size: 12, weight: .medium))
                                                    .foregroundColor(.white.opacity(0.9))
                                            }
                                        }
                                    }
                                }
                                .padding(.top, 8)
                                .padding(.bottom, 20)
                            }
                            .padding(24)
                        }
                    }
                    .tag(index)
                }
            }
            .frame(height: 400)
            .tabViewStyle(PageTabViewStyle())
            .padding(.bottom, 8)
            .onAppear {
                // 启动自动轮播计时器
                startTimer()
                // 获取API数据以显示评论
                fetchApiData()
            }
            .onDisappear {
                // 停止计时器
                stopTimer()
            }
        }
    }
    
    // 开始自动轮播计时器
    private func startTimer() {
        timer = Timer.publish(every: 5, on: .main, in: .common)
        timerCancellable = timer.connect()
        
        // 监听计时器事件，自动切换到下一个标签
        timer
            .autoconnect()
            .sink { _ in
                withAnimation {
                    currentTab = (currentTab - 1 + section.movies.count) % section.movies.count
                }
            }
            .store(in: &setupCancellables)
    }
    
    // 停止计时器
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    // 获取API数据
    private func fetchApiData() {
        APIService.shared.fetchHomeData()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { response in
                    self.apiResponse = response
                }
            )
            .store(in: &setupCancellables)
    }
    
    // 获取电影的评论内容
    private func getReviewContent(for movie: Movie) -> String? {
        guard let apiResponse = apiResponse else { return nil }
        
        // 在banner中查找匹配的电影
        if let dto = apiResponse.banner.first(where: { $0.id == movie.id }) {
            return dto.reviewContent
        }
        return nil
    }
    
    // 获取电影的评论人名称
    private func getReviewName(for movie: Movie) -> String? {
        guard let apiResponse = apiResponse else { return nil }
        
        // 在banner中查找匹配的电影
        if let dto = apiResponse.banner.first(where: { $0.id == movie.id }) {
            return dto.reviewName
        }
        return nil
    }
}

