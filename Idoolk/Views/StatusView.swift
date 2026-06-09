//
//  StatusView.swift
//  Idoolk
//
//  Created by wang k on 2025/4/21.
//

import SwiftUI
import Kingfisher
import Combine

struct StatusView: View {
    @State private var selectedStatus: UserWatchStatus.WatchStatus = .wantToWatch
    @State private var movieIds: [Int] = []
    @State private var movies: [Movie] = []
    @State private var isLoading: Bool = false
    @State private var isFirstLoad: Bool = true
    @ObservedObject private var movieViewModel = MovieViewModel()
    
    var body: some View {
        
        VStack(spacing: 0) {
            // 顶部标题
            HStack {
                Text("我的片单")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(AppColors.text)
                
                Spacer()
            }
            .padding(.horizontal, 17)
            .padding(.bottom, 16)
            
            // 分类标签
            StatusTabBar(selectedStatus: $selectedStatus)
                .padding(.bottom, 16)
            
            // 内容部分
            if isLoading && isFirstLoad {
                Spacer()
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                Spacer()
            } else if movies.isEmpty {
                Spacer()
                VStack(spacing: 16) {
                    Image(statusEmptyIcon())
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text(statusEmptyText())
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(1.2)
                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                            .padding(.top, 10)
                    }
                }
                .padding(.horizontal, 30)
                Spacer()
            } else {
                // 电影列表
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(movies) { movie in
                            NavigationLink(destination: DetailView(movie: movie)) {
                                MovieCardHorizontal(movie: movie)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, UIHelper.bottomSafeAreaInset + 20)
                }
                
                // 如果正在加载，显示底部加载指示器
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                        .padding(.bottom, 10)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .onChange(of: selectedStatus) { newStatus in
            loadMovies(with: newStatus)
        }
        .onAppear {
            // 首次加载时初始化ViewModel
            //            if isFirstLoad {
            //                isFirstLoad = false
            //                // 如果主页没有加载电影数据，先加载主页数据获取电影信息
            //                if movieViewModel.sections.isEmpty {
            //                    movieViewModel.loadData()
            //                        .sink(
            //                            receiveCompletion: { completion in
            //                                switch completion {
            //                                case .finished:
            //                                    loadMovies(with: selectedStatus)
            //                                case .failure:
                            //                                    // 即使API失败，也尝试从本地数据库加载数据
            //                                    loadMovies(with: selectedStatus)
            //                                }
            //                            },
            //                            receiveValue: { _ in }
            //                        )
            //                        .store(in: &movieViewModel.cancellables)
            //                } else {
            //                    loadMovies(with: selectedStatus)
            //                }
            //            } else {
            // 非首次进入页面时刷新当前状态的数据
            loadMovies(with: selectedStatus)
            //            }
        }
    }
    
    // 加载指定状态的电影
    private func loadMovies(with status: UserWatchStatus.WatchStatus) {
        isLoading = true
        
        // 获取指定状态的电影ID
        let movieIds = RealmManager.shared.getMoviesWithStatus(status)
        self.movieIds = movieIds
        
        // 如果有电影ID，则尝试从数据库或内存中加载电影数据
        if !movieIds.isEmpty {
            loadMovieData(for: movieIds)
        } else {
            // 没有相关电影
            self.movies = []
            isLoading = false
        }
    }
    
    // 尝试从不同来源加载电影数据
    private func loadMovieData(for movieIds: [Int]) {
        var loadedMovies: [Movie] = []
        
        // 从MovieViewModel中查找已加载的电影
        for section in movieViewModel.sections {
            for movie in section.movies {
                if movieIds.contains(movie.id) && !loadedMovies.contains(where: { $0.id == movie.id }) {
                    loadedMovies.append(movie)
                }
            }
        }
        
        // 根据SwiftData缓存加载电影详情
        for movieId in movieIds {
            if !loadedMovies.contains(where: { $0.id == movieId }) {
                if let movie = RealmManager.shared.getMovie(for: movieId) {
                    loadedMovies.append(movie)
                }
            }
        }
        
        // 更新UI
        self.movies = loadedMovies.sorted { $0.name < $1.name }
        isLoading = false
    }
    
    // 获取空状态图标
    private func statusEmptyIcon() -> String {
        switch selectedStatus {
        case .wantToWatch:
            return "carrot_icon"
        case .watching:
            return "carrot_icon"
        case .watched:
            return "carrot_icon"
        }
    }
    
    // 获取空状态文本
    private func statusEmptyText() -> String {
        switch selectedStatus {
        case .wantToWatch:
            return "你还没有添加任何想看的剧集\n去首页发现更多精彩内容吧"
        case .watching:
            return "你还没有添加任何在看的剧集\n将正在观看的剧集添加到这里吧"
        case .watched:
            return "你还没有添加任何已看的剧集\n将看过的剧集标记为已看吧"
        }
    }
}

// 状态标签栏
struct StatusTabBar: View {
    @Binding var selectedStatus: UserWatchStatus.WatchStatus
    
    var body: some View {
        HStack(spacing: 30) {
            ForEach([UserWatchStatus.WatchStatus.wantToWatch, .watching, .watched], id: \.self) { status in
                StatusTabButton(
                    title: status.rawValue,
                    isSelected: selectedStatus == status
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedStatus = status
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
}

// 状态标签按钮
struct StatusTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.secondaryText)
                
                Rectangle()
                    .fill(isSelected ? AppColors.primary : Color.clear)
                    .frame(width: 30, height: 4)
                    .cornerRadius(2)
            }
        }
    }
}

// 为MovieViewModel添加扩展以支持返回Publisher
//extension MovieViewModel {
//    func loadData() -> AnyPublisher<Void, APIError> {
//        // 设置本地加载状态
//        isLoading = true
//        errorMessage = nil
//
//        // 使用API服务获取数据
//        return APIService.shared.fetchHomeData()
//            .map { response in
//                // 处理从API获取的数据
//                self.processFetchedData(response)
//                // 返回Void以保持泛型类型
//                return ()
//            }
//            .handleEvents(receiveCompletion: { completion in
//                self.isLoading = false
//
//                if case .failure(let error) = completion {
//                    self.errorMessage = error.message
//                }
//            })
//            .eraseToAnyPublisher()
//    }
//}

#Preview {
    NavigationView {
        StatusView()
    }
}
