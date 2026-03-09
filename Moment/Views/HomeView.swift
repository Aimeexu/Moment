//
//  HomeView.swift
//  Moment
//
//  首页 - 情绪选择
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var searchText: String = ""

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "FEF5E5"),
                    Color(hex: "E8F5E8")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Search bar
                VStack(spacing: 20) {
                    HStack {

                    Text("记录此刻心情")
                            .frame(width: .infinity, alignment: .center)
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "333333"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.white.opacity(0.9))
                                .shadow(
                                    color: Color.black.opacity(0.05),
                                    radius: 8,
                                    x: 0,
                                    y: 2
                                )
                        )


                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 60)
                .padding(.bottom, 46)

                // Emotion Grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Emotion.allEmotions) { emotion in
                            EmotionItemView(emotion: emotion) {
                                viewModel.selectEmotion(emotion)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
            }
        }
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)),
            removal: .opacity.combined(with: .move(edge: .leading))
        ))
    }
}

#Preview {
    HomeView(viewModel: AppViewModel())
}
