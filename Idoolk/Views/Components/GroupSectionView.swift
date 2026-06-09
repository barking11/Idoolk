//
//  GroupSectionView.swift
//  Idoolk
//
//  Created by wang k on 2025/4/27.
//

import SwiftUI
import Kingfisher

struct GroupSectionView: View {
    let groups: [MovieGroup]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 标题
            HStack {
                Text("推荐片单")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(AppColors.text)
                
                Spacer()
                
                NavigationLink(destination: GroupListView(groups: groups)) {
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
            
            // 片单列表
            ForEach(groups, id: \.title) { group in
                NavigationLink(destination: SectionListView(sectionTitle: group.title, movies: group.list.map { $0.toMovie() })) {
                    GroupCardView(group: group)
                }
            }
        }
    }
}

struct GroupCardView: View {
    let group: MovieGroup
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // 封面图叠放效果
            ZStack(alignment: .bottomLeading) {
                // 背景容器
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 120, height: 160)
                
                // 影片封面叠放
                ForEach((0...min(3, group.list.count) - 1).reversed(), id: \.self) { index in
                    if index < group.list.count {
                        let movie = group.list[index]
                        if let path = movie.posterPath {
                            // 使用电影海报
                            KFImage(MovieViewModel().getImageURL(path: path))
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
                                .offset(x: CGFloat(index * 7), y: CGFloat(index * -5))
                                .zIndex(Double(3 - index))
                                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
                        }
                    }
                }
                
                // 片单中的电影数量
                Text("共\(group.list.count)部")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(8)
                    .offset(x: 0, y: -5)
                    .zIndex(4)
            }
            
            // 标题
            Text(group.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColors.text)
                .lineLimit(1)
                .frame(width: 160, alignment: .leading)
                .padding(.top, 20)
            
        }
        .padding(.horizontal)
    }
}

struct GroupListView: View {
    let groups: [MovieGroup]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(groups, id: \.title) { group in
                    NavigationLink(destination: SectionListView(sectionTitle: group.title, movies: group.list.map { $0.toMovie() })) {
                        GroupCardListView(group: group)
                    }
                }
            }
            .padding(16)
        }
        .navigationTitle("推荐片单")
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
    }
}

struct GroupCardListView: View {
    let group: MovieGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            // 封面图叠放效果
            ZStack(alignment: .bottomLeading) {
                // 获取前三部电影（如果有）
                ForEach((0...min(3, group.list.count) - 1).reversed(), id: \.self) { index in
                    if index < group.list.count {
                        let movie = group.list[index]
                        if let path = movie.posterPath {
                            // 使用影片海报
                            KFImage(MovieViewModel().getImageURL(path: path))
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
                                .frame(width:(UIHelper.screenWidth - 100) / 2, height: (UIHelper.screenWidth - 100) / 2 * 1.5)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .offset(x: CGFloat(index * 10), y: CGFloat(index * 7))
                                .zIndex(Double(3 - index))
                                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
                        }
                    }
                }
                
                // 片单中的电影数量
                Text("\(group.list.count)部")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(8)
                    .zIndex(4)
            }
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            
            // 标题
            Text(group.title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(AppColors.text)
                .lineLimit(1)
            
            // 描述
            if !group.desc.isEmpty {
                Text(group.desc)
                    .font(.system(size: 12))
                    .foregroundColor(AppColors.secondaryText)
                    .lineLimit(1)
            }
        }
    }
}

#Preview {
    GroupSectionView(groups: [])
}
