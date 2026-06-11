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
// 首页 Banner 区
struct HomeBannerFeaturedView: View {
    let banners: [HomeBanner]
    @State private var currentTab = 0
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 5, on: .main, in: .common)
    @State private var timerCancellable: Cancellable? = nil
    @State private var setupCancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TabView(selection: $currentTab) {
                ForEach(Array(banners.enumerated()), id: \.element.id) { index, banner in
                    bannerContent(banner)
                    .tag(index)
                }
            }
            .frame(height: 400)
            .tabViewStyle(PageTabViewStyle())
            .padding(.bottom, 8)
            .onAppear {
                startTimer()
            }
            .onDisappear {
                stopTimer()
            }
        }
    }

    @ViewBuilder
    private func bannerContent(_ banner: HomeBanner) -> some View {
        if let movie = banner.targetMovie {
            NavigationLink(destination: DetailView(movie: movie)) {
                bannerCard(banner)
            }
        } else {
            bannerCard(banner)
        }
    }

    private func bannerCard(_ banner: HomeBanner) -> some View {
        ZStack(alignment: .bottomLeading) {
            KFImage(URL(string: banner.imageUrl))
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

            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0), Color.black.opacity(0.5)]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 400)

            LinearGradient(
                gradient: Gradient(colors: [Color.black.opacity(0.82), Color.black.opacity(0)]),
                startPoint: .bottom,
                endPoint: .center
            )
            .frame(height: 400)

            VStack(alignment: .leading, spacing: 8) {
                Text(banner.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)

                if let movie = banner.targetMovie {
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
                }

                HStack(alignment: .top, spacing: 8) {
                    Text("“")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(AppColors.primary.opacity(0.7))
                        .offset(y: -8)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(banner.comment ?? banner.targetMovie?.overview ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(2)

                        if let nickname = banner.userNickname, !nickname.isEmpty {
                            HStack {
                                Spacer()

                                Text("—— \(nickname)")
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
    
    // 开始自动轮播计时器
    private func startTimer() {
        timer = Timer.publish(every: 5, on: .main, in: .common)
        timerCancellable = timer.connect()
        
        // 监听计时器事件，自动切换到下一个标签
        timer
            .autoconnect()
            .sink { _ in
                withAnimation {
                    currentTab = (currentTab + 1) % max(banners.count, 1)
                }
            }
            .store(in: &setupCancellables)
    }
    
    // 停止计时器
    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }
}
