//
//  ContentView.swift
//  Moment
//
//  主内容视图 - 整合所有页面
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = AppViewModel()

    var body: some View {
        ZStack {
            // Background
            Color(hex: "faf8f6")
                .ignoresSafeArea()

            // Main Content
            ZStack {
                switch viewModel.currentPage {
                case .home:
                    HomeView(viewModel: viewModel)
                case .record:
                    RecordView(viewModel: viewModel)
                case .list:
                    ListView(viewModel: viewModel)
                case .settings:
                    SettingsView(viewModel: viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom Tab Bar (hide on record page)
            if viewModel.currentPage != .record {
                VStack {
                    Spacer()
                    TabBarView(currentPage: $viewModel.currentPage)
                }
            }

            // Toast
            if viewModel.showToast {
                VStack {
                    Spacer()
                    ToastView(message: viewModel.toastMessage)
                        .padding(.bottom, 120)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: viewModel.currentPage)
        .animation(.spring(response: 0.3), value: viewModel.showToast)
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: MoodRecord.self, inMemory: true)
}
