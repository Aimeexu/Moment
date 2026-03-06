//
//  ListView.swift
//  Moment
//
//  记录列表页面
//

import SwiftUI

struct ListView: View {
    @ObservedObject var viewModel: AppViewModel

    @State private var showToast: Bool = false

    var body: some View {
        ZStack {
            // Background
            BackgroundDecorations()
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 20) {
                        Text("我的记录")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "a78bfa"), Color(hex: "f5a5d1")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        // Filter Scroll
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(viewModel.filterOptions, id: \.self) { filter in
                                    FilterItemView(
                                        text: filter,
                                        isActive: viewModel.selectedFilter == filter
                                    ) {
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            viewModel.selectedFilter = filter
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)

                    // Records
                    VStack(spacing: 12) {
                        ForEach(viewModel.filteredRecords) { record in
                            RecordItemView(record: record) {
                                showToast = true
                            }
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity
                            ))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .toast(isShowing: $showToast, message: "更多")
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .trailing)),
            removal: .opacity.combined(with: .move(edge: .leading))
        ))
    }
}

struct FilterItemView: View {
    let text: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(isActive ? .white : Color(hex: "8b8b8b"))
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(filterBackground)
                .overlay(
                    Capsule()
                        .stroke(
                            isActive ? Color.clear : Color(hex: "a78bfa").opacity(0.2),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    @ViewBuilder
    private var filterBackground: some View {
        if isActive {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "a78bfa"), Color(hex: "f5a5d1")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        } else {
            Capsule()
                .fill(Color.white.opacity(0.6))
        }
    }
}

#Preview {
    ListView(viewModel: AppViewModel())
}