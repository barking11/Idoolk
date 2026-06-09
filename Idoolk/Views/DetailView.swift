import SwiftUI
import Kingfisher
import Combine
// 导入共享的AIReviewer枚举

// 详情页面视图模型
class DetailViewModel: ObservableObject {
    private let realmManager = RealmManager.shared
    @Published var movie: Movie
    @Published var currentTab: DetailTab = .about
    @Published var watchStatus: UserWatchStatus.WatchStatus?
    @Published var selectedAIReviewer: AIReviewer = .shenZhiYuan
    @Published var isLoadingReview: Bool = false
    @Published var aiReview: String = ""
    @Published var relatedMovies: [Movie] = []
    
    // API数据
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var detailData: TVShowDetailResponse? = nil
    @Published var numberOfEpisodes: Int = 0
    @Published var numberOfSeasons: Int = 0
    @Published var status: String = ""
    @Published var genres: [Genre] = []
    @Published var cast: [Cast] = []
    @Published var recommendations: [RecommendedShow] = []
    
    // 取消器
    var cancellables = Set<AnyCancellable>()
    
    enum DetailTab: String, CaseIterable, Identifiable {
        case about = "关于"
        case details = "详情"
        case aiReview = "AI剧评"
        case related = "相关片单"
        
        var id: String { self.rawValue }
    }
    
    init(movie: Movie) {
        self.movie = movie
        loadWatchStatus()
        fetchTVShowDetail()
    }
    
    func loadWatchStatus() {
        self.watchStatus = realmManager.getWatchStatus(for: movie.id)
    }
    
    func updateWatchStatus(_ status: UserWatchStatus.WatchStatus) {
        if watchStatus == status {
            // 如果点击当前状态，则移除状态
            realmManager.removeWatchStatus(for: movie.id)
            watchStatus = nil
        } else {
            // 否则更新为新状态
            realmManager.saveMovie(movie)
            realmManager.updateWatchStatus(for: movie.id, status: status)
            watchStatus = status
        }
    }
    
    // 从API获取详细数据
    func fetchTVShowDetail() {
        isLoading = true
        errorMessage = nil
        
        // 使用LoadingManager显示加载指示器
        LoadingManager.shared.withLoading(
            message: "正在加载...",
            publisher: APIService.shared.fetchTVShowDetail(id: movie.id)
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.message
                    print("获取详情失败: \(error.message)")
                }
            },
            receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                // 保存响应数据
                self.detailData = response
                
                // 更新UI显示相关数据
                self.numberOfEpisodes = response.numberOfEpisodes
                self.numberOfSeasons = response.numberOfSeasons
                self.status = response.status
                self.genres = response.genres
                self.cast = response.credits.cast
                self.recommendations = response.recommendations.results
                
                // 更新movie对象的详细信息
                self.updateMovieDetails(from: response)
                
                // 保存到SwiftData以便离线访问
                self.saveToLocalStore(response)
                
                // 加载相关电影
                self.loadRelatedMoviesFromRecommendations()
            }
        )
        .store(in: &cancellables)
    }
    
    // 更新电影详情
    private func updateMovieDetails(from response: TVShowDetailResponse) {
        // 部分数据可能在Movie对象中不存在，这里可以创建一个新的Movie对象
        // 或者更新现有Movie对象的属性
    }
    
    // 保存到本地数据库
    private func saveToLocalStore(_ response: TVShowDetailResponse) {
        realmManager.saveMovieDetail(response)
    }
    
    func generateAIReview() {
        isLoadingReview = true
        
        // 使用APIService获取AI影评
        APIService.shared.fetchAIReview(movieName: movie.name, reviewer: selectedAIReviewer)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        break
                    case .failure(_):
                        // 如果API请求失败，使用本地生成的评论作为备用
                        self?.generateLocalAIReview()
                    }
                },
                receiveValue: { [weak self] response in
                    guard let self = self else { return }
                    
                    if let content = response.choices.first?.message.content {
                        self.aiReview = content
                    } else {
                        // 如果无法解析响应，使用本地生成的评论作为备用
                        self.generateLocalAIReview()
                    }
                    
                    self.isLoadingReview = false
                }
            )
            .store(in: &cancellables)
    }
    
    // 本地生成AI评论（作为备用）
    private func generateLocalAIReview() {
        switch selectedAIReviewer {
        case .shenZhiYuan:
            aiReview = "从专业角度来看，《\(movie.name)》是一部构思精巧、制作精良的作品。导演的镜头语言富有创意，演员的表演细腻传神，特别是主演对人物内心情感的把握非常到位。剧情发展节奏适宜，第三幕的转折令人惊艳。这部作品不仅在技术层面达到了行业标准，更在艺术表达上有所突破，值得观众细细品味。"
        case .taoQiQi:
            aiReview = "天呐！《\(movie.name)》简直太好看了！我连续熬夜追完全剧，每集都有惊喜。主角们的化学反应太棒了，那个表白场景我已经看了至少十遍！配乐也超级契合剧情，我已经把原声带列入日常播放列表。这绝对是今年不能错过的神剧，强烈推荐给所有人。已经开始期待第二季了，编剧们真是太有才了！"
        case .zhangDaiFu:
            aiReview = "《\(movie.name)》作为文化产物，反映了当代社会的多重面相。其叙事结构借鉴了传统东方美学，同时融合西方后现代主义元素，形成独特的跨文化对话。作品中呈现的家庭关系、权力结构和社会阶层流动等议题，为我们理解全球化背景下的文化认同提供了新的视角。值得从符号学和性别研究等多维度进行深入分析。"
        }
    }
    
    // 从API推荐列表获取相关电影
    func loadRelatedMoviesFromRecommendations() {
        guard let recommendations = detailData?.recommendations.results else {
            loadRelatedMovies() // 如果API未返回推荐，回退到之前的方法
            return
        }
        
        // 将推荐电视剧转换为Movie模型
        relatedMovies = recommendations.prefix(6).map { show in
            Movie(
                adult: show.adult,
                backdropPath: show.backdropPath,
                genreIds: show.genreIds,
                id: show.id,
                originCountry: show.originCountry,
                originalLanguage: show.originalLanguage,
                originalName: show.originalName,
                overview: show.overview,
                popularity: show.popularity,
                posterPath: show.posterPath,
                firstAirDate: show.firstAirDate,
                name: show.name,
                voteAverage: show.voteAverage,
                voteCount: show.voteCount
            )
        }
    }
    
    // 备用方法：从本地数据获取相关电影（当API不可用时）
    func loadRelatedMovies() {
        // 模拟加载相关电影
        let mockViewModel = MovieViewModel()
        if let firstGenre = movie.genreIds.first {
            // 过滤出同类型的电影，但排除当前电影
            relatedMovies = mockViewModel.sections.flatMap { $0.movies }
                .filter { $0.genreIds.contains(firstGenre) && $0.id != movie.id }
                .prefix(6)
                .map { $0 }
        }
    }
}

struct DetailView: View {
    @StateObject private var viewModel: DetailViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(movie: Movie) {
        _viewModel = StateObject(wrappedValue: DetailViewModel(movie: movie))
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                ZStack(alignment: .top) {
                    // 背景图 - 高斯模糊
                    KFImage(MovieViewModel().getImageURL(path: viewModel.movie.backdropPath, size: "w780"))
                        .placeholder { Color.gray.opacity(0.3) }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.width)
                        .blur(radius: 20)
                        .clipped()
                        .overlay(LinearGradient(
                            gradient: Gradient(colors: [AppColors.background.opacity(0), AppColors.background]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                    
                    VStack(spacing: 0) {
                        // 返回按钮
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.trailing, 8)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, UIHelper.topSafeAreaInset)
                        
                        // 海报和基本信息
                        HeaderView(viewModel: viewModel)
                        
                        // 交互按钮
                        ActionButtonsView(viewModel: viewModel)
                            .padding(.vertical, 20)
                        
                        // Tab 内容
                        TabButtonsView(viewModel: viewModel)
                        
                        // Tab 内容视图
                        TabContentView(viewModel: viewModel)
                            .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .background(AppColors.background.edgesIgnoringSafeArea(.all))
            .ignoresSafeArea()
            .overlay {
                if let errorMessage = viewModel.errorMessage {
                    VStack {
                        Spacer()
                        Text("⚠️ \(errorMessage)")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.8))
                            )
                            .padding(.horizontal)
                        Spacer()
                            .frame(height: 100)
                    }
                }
            }
        }
        .onDisappear {
            // 离开页面时清理加载状态
            //            LoadingManager.shared.hideLoading()
        }
    }
}

// 顶部海报和基本信息
struct HeaderView: View {
    @ObservedObject var viewModel: DetailViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 海报
            KFImage(MovieViewModel().getImageURL(path: viewModel.movie.posterPath))
                .placeholder {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 130)
                .cornerRadius(8)
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 3)
            
            // 基本信息
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.movie.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 8) {
                    // 评分
                    HStack(spacing: 4) {
                        Image("rating_star")
                            .resizable()
                            .frame(width: 15, height: 15)
                        
                        Text(String(format: "%.1f", viewModel.movie.voteAverage))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    Text("·")
                        .foregroundColor(.white.opacity(0.7))
                    
                    // 集数 - 使用API数据
                    Text("共\(viewModel.numberOfEpisodes)集")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // 上映日期
                Text("首播日期: \(formatDate(viewModel.movie.firstAirDate))")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                // 更新状态 - 使用API数据
                HStack(spacing: 6) {
                    Text(viewModel.status == "Ended" ? "已完结" :
                            viewModel.status == "Returning Series" ? "连载中" :
                            viewModel.status == "Canceled" ? "已取消" : "未知状态")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(AppColors.primary)
                }
                .padding(.top, 2)
                
                // 类型 - 使用API中的genres数据
                HStack(spacing: 6) {
                    ForEach(viewModel.genres.prefix(3)) { genre in
                        Text(genre.name)
                            .font(.system(size: 12))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppColors.surface.opacity(0.8))
                            )
                            .foregroundColor(.white.opacity(0.8))
                    }
                    // 如果API未返回数据，回退到使用genreIds
                    if viewModel.genres.isEmpty {
                        ForEach(viewModel.movie.genreIds.prefix(3), id: \.self) { genreId in
                            if let genreText = MovieSection.genreMap[genreId] {
                                Text(genreText)
                                    .font(.system(size: 12))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(AppColors.surface.opacity(0.8))
                                    )
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 20)
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

// 操作按钮视图
struct ActionButtonsView: View {
    @ObservedObject var viewModel: DetailViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // 想看按钮
            StatusButton(
                title: "想看",
                iconName: "heart",
                isSelected: viewModel.watchStatus == .wantToWatch,
                action: {
                    viewModel.updateWatchStatus(.wantToWatch)
                }
            )
            
            // 在看按钮
            StatusButton(
                title: "在看",
                iconName: "play.circle",
                isSelected: viewModel.watchStatus == .watching,
                action: {
                    viewModel.updateWatchStatus(.watching)
                }
            )
            
            // 已看按钮
            StatusButton(
                title: "已看",
                iconName: "checkmark.circle",
                isSelected: viewModel.watchStatus == .watched,
                action: {
                    viewModel.updateWatchStatus(.watched)
                }
            )
        }
        .padding(.horizontal)
    }
}

// 状态按钮通用组件
struct StatusButton: View {
    let title: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(isSelected ? AppColors.primary : AppColors.surface)
                        .frame(width: 52, height: 52)
                        .shadow(color: isSelected ? AppColors.primary.opacity(0.4) : Color.black.opacity(0.1),
                                radius: 4, x: 0, y: 2)
                    
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? AppColors.background : .white.opacity(0.8))
                }
                
                Text(title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColors.primary : .white.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// Tab按钮栏
struct TabButtonsView: View {
    @ObservedObject var viewModel: DetailViewModel
    
    var body: some View {
        
        HStack(spacing: 30) {
            ForEach(DetailViewModel.DetailTab.allCases) { tab in
                TabButton(
                    title: tab.rawValue,
                    isSelected: viewModel.currentTab == tab,
                    action: {
                        withAnimation {
                            viewModel.currentTab = tab
                        }
                    }
                )
            }
        }
        
        .frame(height: 44)
        .padding(.horizontal, UIHelper.standardPadding)
        .padding(.top, 8)
    }
}

// 单个Tab按钮
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                    .padding(.vertical, 8)
                
                Rectangle()
                    .fill(isSelected ? AppColors.primary : Color.clear)
                    .frame(width: 30, height: 3)
                    .cornerRadius(1.5)
            }
        }
        .frame(minWidth: 60)
    }
}

// Tab内容视图
struct TabContentView: View {
    @ObservedObject var viewModel: DetailViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.currentTab {
            case .about:
                AboutTab(viewModel: viewModel)
            case .details:
                DetailsTab(viewModel: viewModel)
            case .aiReview:
                AIReviewTab(viewModel: viewModel)
            case .related:
                RelatedTab(viewModel: viewModel)
            }
        }
        .padding(.top, 16)
        .padding(.horizontal, UIHelper.standardPadding)
    }
}

// 关于标签页
struct AboutTab: View {
    @ObservedObject var viewModel: DetailViewModel
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 20) {
                // 评分区
                RatingSection(rating: viewModel.movie.voteAverage, voteCount: viewModel.movie.voteCount)
                
                // 简介
                ContentSection(title: "简介") {
                    Text(viewModel.detailData?.overview ?? viewModel.movie.overview)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.8))
                        .lineSpacing(4)
                }
                
                // 主演
                ContentSection(title: "主演") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            // 使用API获取的演员数据
                            if viewModel.cast.isEmpty {
                                // 没有API数据时显示静态数据
                                ActorCard(
                                    name: "宋慧乔",
                                    role: "Kang Mo-yeon",
                                    imageUrl: URL(string: "https://image.tmdb.org/t/p/w500/tlAX3f82Mf5h0rznpVBVK7nD2om.jpg")
                                )
                                
                                ActorCard(
                                    name: "宋仲基",
                                    role: "Yoo Shi-jin",
                                    imageUrl: URL(string: "https://image.tmdb.org/t/p/w500/kgjb5OppOVTh5tz3hhnfDVnTvDv.jpg")
                                )
                                
                                ActorCard(
                                    name: "金智媛",
                                    role: "Yoon Myung-joo",
                                    imageUrl: nil
                                )
                            } else {
                                // 使用API返回的演员数据
                                ForEach(viewModel.cast.prefix(10)) { actor in
                                    ActorCard(
                                        name: actor.name,
                                        role: actor.character,
                                        imageUrl: actor.profilePath != nil ?
                                        URL(string: "https://image.tmdb.org/t/p/w500\(actor.profilePath!)") : nil
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 2)
                    }
                }
                
                // 季节信息
                //                if viewModel.numberOfSeasons > 0 {
                //                    ContentSection(title: "季") {
                //                        if let seasons = viewModel.detailData?.seasons, !seasons.isEmpty {
                //                            ScrollView(.horizontal, showsIndicators: false) {
                //                                HStack(spacing: 15) {
                //                                    ForEach(seasons) { season in
                //                                        SeasonCard(season: season)
                //                                    }
                //                                }
                //                                .padding(.horizontal, 2)
                //                            }
                //                        } else {
                //                            Text("暂无季节信息")
                //                                .font(.system(size: 15))
                //                                .foregroundColor(.white.opacity(0.6))
                //                        }
                //                    }
                //                }
            }
            .padding(.bottom, 40)
        }
    }
}

// 评分部分
struct RatingSection: View {
    let rating: Double
    let voteCount: Int
    
    private var startBarWidth: Double {
        UIHelper.screenWidth - UIHelper.standardPadding * 2 - 60 - 100 - 10 - 70
    }
    
    // 计算总评分人数
    private var totalVotes: Int {
        return voteCount
    }
    
    private var ratingDistribution: [Int: Int] {
        return RatingDistribution.generateRatingDistribution(voteCount: voteCount, rating: rating)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // 总评分
            VStack(spacing: 8) {
                Text(String(format: "%.1f", rating))
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= Int(rating / 2) ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                    }
                }
                
                Text("\(voteCount)人评分")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(width: 100)
            
            // 评分分布图
            VStack(alignment: .leading, spacing: 4) {
                ForEach((1...5).reversed(), id: \.self) { stars in
                    HStack(spacing: 8) {
                        Text("\(stars)星")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 30, alignment: .trailing)
                        
                        // 评分条
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: startBarWidth, height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(starColor(stars))
                                .frame(width: starBarWidth(stars, total: totalVotes), height: 8)
                                .cornerRadius(4)
                        }
                        
                        Text("\(ratingDistribution[stars] ?? 0)")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 40, alignment: .leading)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.surface.opacity(0.6))
        .cornerRadius(12)
    }
    
    // 评分条颜色
    private func starColor(_ stars: Int) -> Color {
        switch stars {
        case 5: return Color.green
        case 4: return Color.mint
        case 3: return Color.yellow
        case 2: return Color.orange
        case 1: return Color.red
        default: return Color.gray
        }
    }
    
    // 评分条宽度计算
    private func starBarWidth(_ stars: Int, total: Int) -> CGFloat {
        let count = ratingDistribution[stars] ?? 0
        return CGFloat(count) / CGFloat(total) * startBarWidth
    }
}

// 演员卡片
struct ActorCard: View {
    let name: String
    let role: String
    let imageUrl: URL?
    
    var body: some View {
        VStack(spacing: 8) {
            // 演员照片
            KFImage(imageUrl)
                .placeholder {
                    Image(systemName: "person.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                        .frame(width: 90, height: 90)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 90, height: 90)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            // 演员名字
            Text(name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            
            // 角色名字
            Text(role)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .frame(width: 100)
    }
}

// 详情标签页
struct DetailsTab: View {
    @ObservedObject var viewModel: DetailViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let details = viewModel.detailData {
                    // 基本信息
                    ContentSection(title: "基本信息") {
                        InfoRow(title: "原名", value: details.originalName)
                        InfoRow(title: "语言", value: details.languages.joined(separator: ", "))
                        InfoRow(title: "首播", value: formatDate(details.firstAirDate))
                        InfoRow(title: "最后更新", value: formatDate(details.lastAirDate))
                        InfoRow(title: "状态", value: getStatusText(details.status))
                        InfoRow(title: "类型", value: details.genres.map { $0.name }.joined(separator: ", "))
                        InfoRow(title: "制作公司", value: details.productionCompanies.map { $0.name }.joined(separator: ", "))
                        InfoRow(title: "国家", value: details.productionCountries.map { $0.name }.joined(separator: ", "))
                    }
                    
                    // 季信息
                    ContentSection(title: "剧集信息") {
                        InfoRow(title: "季数", value: "\(details.numberOfSeasons)")
                        InfoRow(title: "总集数", value: "\(details.numberOfEpisodes)")
                        if let runtime = details.episodeRunTime.first {
                            InfoRow(title: "每集时长", value: "\(runtime) 分钟")
                        }
                        
                        // 最新剧集信息
                        if let lastEpisode = details.lastEpisodeToAir {
                            Divider()
                                .background(Color.white.opacity(0.2))
                                .padding(.vertical, 10)
                            
                            Text("最新剧集")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.bottom, 10)
                            
                            InfoRow(title: "剧集名", value: lastEpisode.name)
                            InfoRow(title: "播出日期", value: formatDate(lastEpisode.airDate))
                            InfoRow(title: "季", value: "第 \(lastEpisode.seasonNumber) 季")
                            InfoRow(title: "集", value: "第 \(lastEpisode.episodeNumber) 集")
                        }
                    }
                    
                    // 网络平台
                    if !details.networks.isEmpty {
                        ContentSection(title: "播出平台") {
                            ForEach(details.networks, id: \.id) { network in
                                HStack(alignment: .center, spacing: 16) {
                                    if let logoPath = network.logoPath {
                                        KFImage(URL(string: "https://image.tmdb.org/t/p/w500\(logoPath)"))
                                            .placeholder {
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.2))
                                                    .frame(width: 60, height: 30)
                                            }
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 60, height: 30)
                                    }
                                    
                                    Text(network.name)
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    
                    // 外部链接
                    if !details.homepage.isEmpty {
                        ContentSection(title: "官方网站") {
                            Button(action: {
                                if let url = URL(string: details.homepage) {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text(details.homepage)
                                    .font(.system(size: 16))
                                    .foregroundColor(AppColors.primary)
                                    .underline()
                            }
                        }
                    }
                } else {
                    // 基本信息 - 无API数据时使用静态数据
                    ContentSection(title: "基本信息") {
                        InfoRow(title: "原名", value: viewModel.movie.originalName)
                        InfoRow(title: "语言", value: viewModel.movie.originalLanguage)
                        InfoRow(title: "首播", value: formatDate(viewModel.movie.firstAirDate))
                        InfoRow(title: "类型", value: viewModel.movie.genreIds.compactMap { MovieSection.genreMap[$0] }.joined(separator: ", "))
                    }
                }
            }
            .padding(.bottom, 40)
        }
    }
    
    // 获取状态文字
    private func getStatusText(_ status: String) -> String {
        switch status {
        case "Returning Series":
            return "连载中"
        case "Ended":
            return "已完结"
        case "Canceled":
            return "已取消"
        default:
            return status
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

// 详情行
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// AI剧评标签页
struct AIReviewTab: View {
    @ObservedObject var viewModel: DetailViewModel
    @State private var selectedCritic: AIReviewer? = nil
    @State private var showReview: Bool = false
    
    // 用于存储订阅
    static var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 25) {
                
                // AI评论家列表
                VStack(spacing: 20) {
                    // 第一个评论家 - 左对齐
                    CriticCard(
                        critic: .shenZhiYuan,
                        viewModel: viewModel,
                        selectedCritic: $selectedCritic,
                        showReview: $showReview,
                        reviewText: $viewModel.aiReview,
                        movieName: viewModel.movie.name,
                        alignment: .leading
                    )
                    
                    // 第二个评论家 - 右对齐
                    CriticCard(
                        critic: .taoQiQi,
                        viewModel: viewModel,
                        selectedCritic: $selectedCritic,
                        showReview: $showReview,
                        reviewText: $viewModel.aiReview,
                        movieName: viewModel.movie.name,
                        alignment: .trailing
                    )
                    
                    // 第三个评论家 - 左对齐
                    CriticCard(
                        critic: .zhangDaiFu,
                        viewModel: viewModel,
                        selectedCritic: $selectedCritic,
                        showReview: $showReview,
                        reviewText: $viewModel.aiReview,
                        movieName: viewModel.movie.name,
                        alignment: .leading
                    )
                }
                
                Spacer(minLength: 50)
            }
        }
        .onChange(of: selectedCritic) { _, newValue in
            guard let newValue else { return }
            viewModel.isLoadingReview = true
            viewModel.selectedAIReviewer = newValue
            viewModel.generateAIReview()
        }
    }
}

// AI剧评详情页
struct AIReviewDetailView: View {
    @ObservedObject var viewModel: DetailViewModel
    let critic: AIReviewer
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack(spacing: 14) {
                    Image(uiImage: UIImage(named: critic.iconName) ?? UIImage(systemName: critic.placeholderIcon)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(LinearGradient(
                                    gradient: Gradient(colors: critic.gradientColors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ), lineWidth: 2)
                        )
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(critic.rawValue)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text(viewModel.movie.name)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white.opacity(0.72))
                    }
                    
                    Spacer()
                }
                
                if viewModel.isLoadingReview {
                    AIReviewLoadingView()
                    .frame(minHeight: 220)
                } else {
                    Text(viewModel.aiReview)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.92))
                        .lineSpacing(8)
                        .padding(18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColors.surface.opacity(0.55))
                        )
                }
            }
            .padding(20)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("AI剧评")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AIReviewLoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 14) {
            Image("loading_icon")
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 1.4)
                    .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            Text("评论员们正在热烈讨论...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.72))
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            isAnimating = true
        }
    }
}

// AI评论家卡片
struct CriticCard: View {
    let critic: AIReviewer
    @ObservedObject var viewModel: DetailViewModel
    @Binding var selectedCritic: AIReviewer?
    @Binding var showReview: Bool
    @Binding var reviewText: String
    let movieName: String
    var alignment: Alignment
    
    var body: some View {
        HStack {
            if alignment == .trailing {
                Spacer()
            }
            
            VStack(alignment: alignment == .leading ? .leading : .trailing, spacing: 12) {
                // 头像和名称
                HStack(spacing: 12) {
                    if alignment == .trailing {
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text(critic.rawValue)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(critic.description)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.trailing)
                                .lineLimit(2)
                        }
                    }
                    
                    Image(uiImage: UIImage(named: critic.iconName) ?? UIImage(systemName: critic.placeholderIcon)!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(LinearGradient(
                                    gradient: Gradient(colors: critic.gradientColors),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ), lineWidth: 2)
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                    
                    if alignment == .leading {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(critic.rawValue)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(critic.description)
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                    }
                }
                
                // 评论按钮
                NavigationLink {
                    AIReviewDetailView(viewModel: viewModel, critic: critic)
                } label: {
                    Text("听他的评论")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: critic.gradientColors),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: critic.gradientColors[0].opacity(0.4), radius: 4, x: 0, y: 2)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    selectedCritic = critic
                    showReview = true
                })
                .padding(.top, 4)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.9)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.surface.opacity(0.5))
            )
            
            if alignment == .leading {
                Spacer()
            }
        }
        .padding(.horizontal, 8)
    }
}

// 相关片单标签页
struct RelatedTab: View {
    @ObservedObject var viewModel: DetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if viewModel.relatedMovies.isEmpty {
                VStack(spacing: 10) {
                    Spacer()
                    Text("暂无相关剧集")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 300)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.relatedMovies) { movie in
                        NavigationLink(destination: DetailView(movie: movie)) {
                            MovieCardForGrid(movie: movie)
                        }
                    }
                }
            }
        }
    }
}

// 用于网格布局的电影卡片
struct MovieCardForGrid: View {
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
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                }
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // 标题
            Text(movie.name)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
            
            // 评分
            HStack(spacing: 4) {
                Image("rating_star")
                    .resizable()
                    .frame(width: 12, height: 12)
                
                Text(String(format: "%.1f", movie.voteAverage))
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}

// 内容区域包装组件
struct ContentSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
            
            content
        }
        .padding(.bottom, 20)
    }
}

// 季节卡片组件
struct SeasonCard: View {
    let season: Season
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // 海报
            if let posterPath = season.posterPath {
                KFImage(URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)"))
                    .placeholder {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 180)
                    .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 180)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            
            // 季节名称
            Text(season.name)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .lineLimit(1)
            
            // 集数
            Text("\(season.episodeCount)集")
                .font(.system(size: 13))
                .foregroundColor(AppColors.secondary)
        }
        .frame(width: 120)
    }
}

// 预览
#Preview {
    let movie = Movie(
        adult: false,
        backdropPath: "/o9Z8O0gdi6Qvvzk86RdnnBjBGDq.jpg",
        genreIds: [18, 10759],
        id: 65143,
        originCountry: ["KR"],
        originalLanguage: "ko",
        originalName: "태양의 후예",
        overview: "特战警备队大尉柳时镇（宋仲基 饰）与上士徐大荣（晋久 饰）休假之时遭遇激斗事件，送小偷去医院的时候，被主任医师姜暮烟（宋慧乔 饰）误会，也引得徐大荣的前女友尹明珠（金智媛 饰）突然出现，姜暮烟因此与柳时镇结缘，可是由于立场不同最终不欢而散。一次意外派遣，姜暮烟又与柳时镇相遇在战火频发的乌鲁克，作为海外医疗派遣队队长的姜暮烟与柳时镇无数次并肩作战，感情得到了升华。可是回国后姜暮烟面对柳时镇出生入死的工作又开始了新一轮担忧，与此同时，徐大荣与尹明珠的爱情也再次遇到了威胁。",
        popularity: 7.6957,
        posterPath: "/oFCgaGKIqLiTEcbwPOJUWJFfhyD.jpg",
        firstAirDate: "2016-02-24",
        name: "太阳的后裔",
        voteAverage: 8.344,
        voteCount: 732
    )
    
    return DetailView(movie: movie)
}
