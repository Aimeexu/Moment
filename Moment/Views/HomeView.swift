//
//  HomeView.swift
//  Moment
//
//  首页 - 情绪选择
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AppViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
    ]

    var body: some View {
        ZStack {
            // Background
            BackgroundDecorations()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Text("情绪云朵")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "a78bfa"), Color(hex: "f5a5d1")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )

                    Text("记录此刻的心情，温暖你的每一天")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(hex: "8b8b8b"))
                        .tracking(0.5)
                }
                .padding(.top, 50)
                .padding(.bottom, 30)

                // Emotion Grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(Emotion.allEmotions) { emotion in
                            EmotionItemView(emotion: emotion) {
                                viewModel.selectEmotion(emotion)
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 100)
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