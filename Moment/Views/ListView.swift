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
            // Background gradient - matching HomeView
            LinearGradient(
                colors: [
                    Color(hex: "FEF5E5"),
                    Color(hex: "E8F5E8")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Filter Scroll - moved to top for better UX
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.filterOptions, id: \.self) { filter in
                                FilterItemView(
                                    filterOption: filter,
                                    isActive: viewModel.selectedFilter == filter
                                ) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        viewModel.selectedFilter = filter
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 24)

                    // Records
                    LazyVStack(spacing: 16) {
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
    let filterOption: FilterOption
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Show image for emotion filters, nothing for "全部"
                if let imageName = filterOption.imageName {
                    Image(imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                }
                
                Text(filterOption.text)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isActive ? .white : Color(hex: "666666"))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 2)
            .background(filterBackground)
            .clipShape(Capsule())
            .shadow(
                color: isActive ? Color(hex: "a78bfa").opacity(0.3) : Color.clear,
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isActive ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isActive)
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
                .fill(Color.white.opacity(0.8))
                .overlay(
                    Capsule()
                        .stroke(Color(hex: "e5e5e5"), lineWidth: 1)
                )
        }
    }
}

#Preview {
    ListView(viewModel: AppViewModel())
}
