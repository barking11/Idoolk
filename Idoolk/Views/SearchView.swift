//
//  SearchView.swift
//  Idoolk
//
//  Created by wang k on 2025/4/4.
//

import SwiftUI
import Combine

struct SearchView: View {
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var searchResults: [Movie] = []
    @State private var errorMessage: String? = nil
    @Environment(\.presentationMode) var presentationMode
    
    // 保存取消器以防止内存泄漏
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        VStack(spacing: 0) {
            // 搜索框
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .foregroundColor(AppColors.text)
                        .padding(.trailing, 8)
                }
                
                HStack {
                    Image("search_icon")
                        .resizable()
                        .frame(width: 20, height: 20)
                    
                    TextField("搜索", text: $searchText)
                        .font(.system(size: 15))
                        .foregroundColor(AppColors.text)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .onSubmit {
                            performSearch()
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppColors.secondaryText)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                
                Button(action: {
                    performSearch()
                }) {
                    Text("搜索")
                        .foregroundColor(AppColors.primary)
                        .padding(.leading, 8)
                }
            }
            .padding()
            
            // 搜索结果或占位文本
            if isSearching {
                // 搜索中
                Spacer()
            } else if let error = errorMessage {
                // 错误信息
                VStack {
                    Spacer()
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.secondaryText)
                        .padding()
                    
                    Text(error)
                        .font(.headline)
                        .foregroundColor(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Spacer()
                }
            } else if !searchResults.isEmpty {
                // 搜索结果列表
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(searchResults) { movie in
                            NavigationLink(destination: DetailView(movie: movie)) {
                                MovieCardHorizontal(movie: movie)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, UIHelper.bottomSafeAreaInset + 20)
                }
            } else if !searchText.isEmpty {
                // 无结果提示
                VStack {
                    Spacer()
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(AppColors.secondaryText)
                        .padding()
                    
                    Text("没有找到相关结果")
                        .font(.headline)
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text("请尝试其他关键词")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryText.opacity(0.7))
                        .padding(.top, 4)
                    
                    Spacer()
                }
            } else {
                // 初始占位符
                VStack {
                    Spacer()
                    Image("carrot_icon")
                        .padding()
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text("搜索你要追的剧")
                        .font(.headline)
                        .foregroundColor(AppColors.secondaryText)
                    
//                    Text("结果将显示在这里")
//                        .font(.subheadline)
//                        .foregroundColor(AppColors.secondaryText.opacity(0.7))
//                        .padding(.top, 4)
                    
                    Spacer()
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationBarHidden(true)
    }
    
    // 执行搜索
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        errorMessage = nil
        searchResults = []
        
        // 取消之前的所有订阅
        cancellables.removeAll()
        
        LoadingManager.shared.withLoading(
            message: "正在搜索...",
            publisher: APIService.shared.searchMovies(query: searchText)
        )
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                isSearching = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    errorMessage = error.message
                }
            },
            receiveValue: { response in
                searchResults = response.results.map { $0.toMovie() }
                isSearching = false
            }
        )
        .store(in: &cancellables)
    }
}
