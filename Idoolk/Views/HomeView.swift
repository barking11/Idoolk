import SwiftUI
import Combine
import Kingfisher

struct HomeView: View {
    @StateObject private var viewModel = MovieViewModel()
    @State private var searchText = ""
    @State private var showCalendar = false
    @State private var showSearchScreen = false
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        ZStack(alignment: .top) {
            // 背景色
            AppColors.background.ignoresSafeArea()
            
            // 主内容
            ScrollView {
                VStack(spacing: 0) {
                    // 特别推荐区 - 从顶部开始
                    if !viewModel.sections.isEmpty {
                        MovieSectionFeatured(section: viewModel.sections[0])
                            .padding(.top, 0)
                    }
                    
                    // 分区内容
                    LazyVStack(spacing: 0, pinnedViews: []) {
                        ForEach(Array(viewModel.sections.enumerated()), id: \.offset) { index, section in
                            if index > 0 { // 跳过第一个，因为已经在特别推荐区显示
                                if index == 1 || index == 2 {
                                    MovieSectionRegular(section: section)
                                        .padding(.bottom, 30)
                                } else {
                                    MovieSectionList(section: section)
                                        .padding(.bottom, 30)
                                }
                            }
                        }
                        
                        // 添加推荐片单组件
                        if !viewModel.movieGroups.isEmpty {
                            GroupSectionView(groups: viewModel.movieGroups)
                                .padding(.bottom, 30)
                        }
                    }
                    .padding(.top, 16)
                    
                    // 底部间距
                    Spacer(minLength: 80)
                }
            }
            .refreshable {
                // 下拉刷新
                viewModel.loadData()
            }
            .overlay {
                // 加载中或错误信息
                //                if viewModel.isLoading {
                //                    VStack {
                //                        Spacer()
                //                        ProgressView()
                //                            .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                //                            .scaleEffect(1.5)
                //                        Text("加载中...")
                //                            .font(.system(size: 14))
                //                            .foregroundColor(AppColors.secondaryText)
                //                            .padding(.top, 8)
                //                        Spacer()
                //                    }
                //                    .frame(maxWidth: .infinity)
                //                    .background(Color.black.opacity(0.3))
                //                }
                
                if let errorMessage = viewModel.errorMessage, !viewModel.isLoading {
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
                        Spacer()
                            .frame(height: 100)
                    }
                }
            }
            .edgesIgnoringSafeArea(.all) // 忽略安全区域，实现真正的全屏
            
            // 顶部搜索区域 - 悬浮在特别推荐区上方
            HStack(spacing: 16) {
                // 日历按钮
                Button(action: {
                    showCalendar.toggle()
                }) {
                    Image("home_calendar")
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(AppColors.surface.opacity(0.8))
                                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        )
                }
                
                // 搜索框 - 点击跳转
                Button(action: {
                    showSearchScreen = true
                }) {
                    HStack {
                        Image("search_icon")
                            .resizable()
                            .frame(width: 20, height: 20)
                        
                        Text("搜索你要追的剧")
                            .foregroundColor(AppColors.secondaryText)
                            .font(.system(size: 15))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppColors.surface.opacity(0.8))
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 0)
            .padding(.bottom, 8)
            .zIndex(1) // 确保搜索区域显示在最上层
        }
        .navigationBarHidden(true) // 隐藏导航栏
        .sheet(isPresented: $showCalendar) {
            ScheduleView()
                .presentationDetents([.large])
        }
        .onAppear {
            // 如果数据为空，则加载数据
            if viewModel.sections.isEmpty {
                viewModel.loadData()
            }
        }
        .onChange(of: appState.needsRefresh) { newValue in
            // 应用从后台返回时刷新数据
            if newValue {
                viewModel.loadData()
            }
        }
        .navigationDestination(isPresented: $showSearchScreen) {
            SearchView()
        }
    }
}

// 修改MovieSectionFeatured组件
//struct MovieSectionFeatured: View {
//    let section: MovieSection
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            // 标题
//            HStack {
//                Text(section.title)
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(AppColors.text)
//
//                Spacer()
//
//                Button(action: {}) {
//                    HStack(spacing: 4) {
//                        Text("查看全部")
//                            .font(.system(size: 14))
//                            .foregroundColor(AppColors.primary)
//
//                        Image(systemName: "chevron.right")
//                            .font(.system(size: 12))
//                            .foregroundColor(AppColors.primary)
//                    }
//                }
//            }
//            .padding(.horizontal)
//            .padding(.top, 16)
//
//            // 横滑内容
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack(spacing: 16) {
//                    ForEach(section.movies) { movie in
//                        NavigationLink(destination: DetailView(movie: movie)) {
//                            MovieCardFeatured(movie: movie)
//                                .frame(width: UIScreen.main.bounds.width - 32)
//                        }
//                    }
//                }
//                .padding(.horizontal)
//            }
//        }
//    }
//}

// 修改MovieSectionRegular组件
struct MovieSectionRegular: View {
    let section: MovieSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                Text(section.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.text)
                
                Image(section.title == "最新上线" ? "section_new_icon" : "section_hot_icon")
                
                Spacer()
                
                NavigationLink(destination: SectionListView(sectionTitle: section.title, movies: section.movies)) {
                    HStack(spacing: 4) {
                        Text("更多")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.secondaryText)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            .padding(.horizontal)
            
            // 横滑内容
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(section.movies, id: \.id) { movie in
                        NavigationLink(destination: DetailView(movie: movie)) {
                            MovieCardRegular(movie: movie)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// 修改MovieSectionList组件
struct MovieSectionList: View {
    let section: MovieSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                Text(section.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.text)
                
                Spacer()
                
                NavigationLink(destination: SectionListView(sectionTitle: section.title, movies: section.movies)) {
                    HStack(spacing: 4) {
                        Text("更多")
                            .font(.system(size: 13))
                            .foregroundColor(AppColors.secondaryText)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
            }
            .padding(.horizontal)
            
            // 垂直列表
            VStack(spacing: 12) {
                ForEach(section.movies.prefix(3), id: \.id) { movie in
                    NavigationLink(destination: DetailView(movie: movie)) {
                        MovieCardHorizontal(movie: movie)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

