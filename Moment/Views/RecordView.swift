//
//  RecordView.swift
//  Moment
//
//  记录页面 - 记录情绪
//

import SwiftUI
import PhotosUI
import UIKit

struct RecordView: View {
    @ObservedObject var viewModel: AppViewModel

    var body: some View {
        ZStack {
            // Background with soft gradient
            LinearGradient(
                colors: [
                    Color(hex: "fef7ed"),
                    Color(hex: "f0fdf4"),
                    Color(hex: "eff6ff")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle decorative elements
            BackgroundDecorations()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    RecordHeaderView(
                        onBack: { viewModel.goHome() },
                        onSave: { viewModel.saveRecord() },
                        canSave: viewModel.canSave
                    )

                    // Emotion Show
                    if let emotion = viewModel.selectedEmotion {
                        VStack(spacing: 16) {
                            // Character Container - 缩小尺寸
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.9),
                                            Color(hex: "f8fafc").opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 160, height: 160)
                                .overlay(
                                    // Character Image or Emoji
                                    Group {
                                        if let image = UIImage(named: emotion.imageName) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 120, height: 120)
                                        } else {
                                            // Cute character design fallback
                                            ZStack {
                                                // Character body
                                                Circle()
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [
                                                                Color(hex: "fef3e2"),
                                                                Color(hex: "fde68a")
                                                            ],
                                                            startPoint: .top,
                                                            endPoint: .bottom
                                                        )
                                                    )
                                                    .frame(width: 90, height: 90)
                                                
                                                // Character face
                                                VStack(spacing: 6) {
                                                    // Eyes
                                                    HStack(spacing: 12) {
                                                        Circle()
                                                            .fill(Color.black)
                                                            .frame(width: 6, height: 6)
                                                        Circle()
                                                            .fill(Color.black)
                                                            .frame(width: 6, height: 6)
                                                    }
                                                    
                                                    // Mouth based on emotion
                                                    emotionMouth(for: emotion.name)
                                                }
                                                .offset(y: -6)
                                                
                                                // Character details (like the red crest in image)
                                                if emotion.name == "Happy" {
                                                    Ellipse()
                                                        .fill(Color(hex: "f87171"))
                                                        .frame(width: 18, height: 12)
                                                        .offset(y: -50)
                                                }
                                            }
                                        }
                                    }
                                )
                                .shadow(
                                    color: Color.black.opacity(0.08),
                                    radius: 12,
                                    x: 0,
                                    y: 6
                                )

                            // Emotion Label
                            Text(emotion.name)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color(hex: "374151"))
                        }
                        .padding(.vertical, 20)
                    }

                    // Tabs
                    RecordTabsView(
                        selectedTab: viewModel.recordTab,
                        onSelect: { viewModel.switchTab($0) }
                    )

                    // Input Panel
                    RecordInputPanel(
                        selectedTab: viewModel.recordTab,
                        isRecording: viewModel.isRecording,
                        recordingDuration: viewModel.recordingDuration,
                        textContent: $viewModel.textContent,
                        viewModel: viewModel,
                        onRecordToggle: {
                            if viewModel.isRecording {
                                viewModel.stopRecording()
                            } else {
                                viewModel.startRecording()
                            }
                        }
                    )

                    // Tags
                    TagsAreaView(
                        tags: viewModel.availableTags,
                        selectedTags: viewModel.selectedTags,
                        onTagToggle: { viewModel.toggleTag($0) }
                    )
                    
                    // 底部安全区域
                    Spacer()
                        .frame(height: 100)
                }
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            // 确保顶部有足够的安全区域
            Color.clear.frame(height: 0)
        }
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .leading)),
            removal: .opacity.combined(with: .move(edge: .trailing))
        ))
    }
    
    // Helper function to create emotion-specific mouth
    @ViewBuilder
    private func emotionMouth(for emotionName: String) -> some View {
        switch emotionName.lowercased() {
        case "happy", "loved", "proud":
            // Happy smile
            Arc(startAngle: .degrees(0), endAngle: .degrees(180), clockwise: false)
                .stroke(Color.black, lineWidth: 2)
                .frame(width: 16, height: 8)
        case "sad", "down":
            // Sad frown
            Arc(startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
                .stroke(Color.black, lineWidth: 2)
                .frame(width: 16, height: 8)
        case "angry":
            // Angry line
            Rectangle()
                .fill(Color.black)
                .frame(width: 12, height: 2)
        case "anxious", "tired":
            // Wavy mouth
            Path { path in
                path.move(to: CGPoint(x: 0, y: 4))
                path.addQuadCurve(to: CGPoint(x: 8, y: 4), control: CGPoint(x: 4, y: 0))
                path.addQuadCurve(to: CGPoint(x: 16, y: 4), control: CGPoint(x: 12, y: 8))
            }
            .stroke(Color.black, lineWidth: 2)
            .frame(width: 16, height: 8)
        default:
            // Neutral mouth
            Ellipse()
                .fill(Color.black)
                .frame(width: 8, height: 4)
        }
    }
}

// Arc shape for mouth
struct Arc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var clockwise: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), 
                   radius: rect.width / 2, 
                   startAngle: startAngle, 
                   endAngle: endAngle, 
                   clockwise: clockwise)
        return path
    }
}

struct RecordHeaderView: View {
    let onBack: () -> Void
    let onSave: () -> Void
    let canSave: Bool

    var body: some View {
        HStack {
            // Back Button
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "374151"))
                    .frame(width: 44, height: 44)
            }

            Spacer()

            // Title with rounded background
            Text("记录此刻心情")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(hex: "374151"))
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.8))
                        .shadow(
                            color: Color.black.opacity(0.05),
                            radius: 4,
                            x: 0,
                            y: 2
                        )
                )

            Spacer()

            // Save Button - 灰色样式
            Button(action: onSave) {
                Text("保存")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(canSave ? Color(hex: "374151") : Color(hex: "9ca3af"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(canSave ? Color.white.opacity(0.9) : Color.white.opacity(0.5))
                            .shadow(
                                color: Color.black.opacity(canSave ? 0.05 : 0.02),
                                radius: canSave ? 4 : 2,
                                x: 0,
                                y: canSave ? 2 : 1
                            )
                    )
            }
            .disabled(!canSave)
            .animation(.easeInOut(duration: 0.2), value: canSave)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 16)
    }
}

struct RecordTabsView: View {
    let selectedTab: RecordTab
    let onSelect: (RecordTab) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(RecordTab.allCases, id: \.self) { tab in
                Button(action: { onSelect(tab) }) {
                    Text(tabTitle(for: tab))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(selectedTab == tab ? Color(hex: "374151") : Color(hex: "9ca3af"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            VStack {
                                Spacer()
                                if selectedTab == tab {
                                    Rectangle()
                                        .fill(Color(hex: "f472b6"))
                                        .frame(height: 3)
                                        .clipShape(Capsule())
                                        .transition(.scale.combined(with: .opacity))
                                }
                            }
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedTab)
    }

    private func tabTitle(for tab: RecordTab) -> String {
        switch tab {
        case .voice: return "语音"
        case .text: return "文字"
        case .image: return "图片"
        }
    }
}

struct RecordInputPanel: View {
    let selectedTab: RecordTab
    let isRecording: Bool
    let recordingDuration: TimeInterval
    @Binding var textContent: String
    let viewModel: AppViewModel
    let onRecordToggle: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .voice:
                VoicePanelView(
                    isRecording: isRecording,
                    duration: recordingDuration,
                    onToggle: onRecordToggle
                )
            case .text:
                TextPanelView(textContent: $textContent)
            case .image:
                ImagePanelView(viewModel: viewModel)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .onTapGesture {
            // 点击空白区域收回键盘
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

struct VoicePanelView: View {
    let isRecording: Bool
    let duration: TimeInterval
    let onToggle: () -> Void
    
    @State private var recordedDuration: TimeInterval = 0
    @State private var hasRecorded: Bool = false
    @State private var isPressed: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // Outer glow effect when recording - 缩小尺寸
                if isRecording {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color(hex: "f472b6").opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 35,
                                endRadius: 55
                            )
                        )
                        .frame(width: 110, height: 110)
                        .scaleEffect(isRecording ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isRecording)
                }
                
                // Main recording button - 缩小尺寸
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "f472b6"),
                                Color(hex: "ec4899")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(
                        color: Color(hex: "f472b6").opacity(0.4),
                        radius: isRecording ? 16 : 8,
                        x: 0,
                        y: isRecording ? 8 : 4
                    )

                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.white)
            }
            .scaleEffect(isRecording || isPressed ? 1.05 : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.7),
                value: isRecording || isPressed
            )
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isPressed && !isRecording {
                            isPressed = true
                            onToggle() // 开始录音
                        }
                    }
                    .onEnded { _ in
                        if isPressed && isRecording {
                            isPressed = false
                            recordedDuration = duration
                            hasRecorded = true
                            onToggle() // 停止录音
                        }
                    }
            )

            if isRecording {
                VStack(spacing: 8) {
                    // Recording indicator with animated dots
                    HStack(spacing: 4) {
                        Text("录音中")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "6b7280"))
                        
                        HStack(spacing: 2) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(Color(hex: "f472b6"))
                                    .frame(width: 3, height: 3)
                                    .scaleEffect(isRecording ? 1.0 : 0.5)
                                    .animation(
                                        .easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                        value: isRecording
                                    )
                            }
                        }
                    }
                    
                    Text(formattedDuration(duration))
                        .font(.system(size: 20, weight: .light, design: .monospaced))
                        .foregroundColor(Color(hex: "f472b6"))
                        .tracking(1)
                }
            } else if hasRecorded && recordedDuration > 0 {
                VStack(spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "10b981"))
                        
                        Text("录音完成")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "374151"))
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "waveform")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "f472b6"))
                        
                        Text(formattedDuration(recordedDuration))
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundColor(Color(hex: "f472b6"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(hex: "f472b6").opacity(0.1))
                    )
                }
            } else {
                Text("长按开始录音")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "9ca3af"))
            }
        }
        .padding(.vertical, 20)
        .onChange(of: duration) { oldValue, newDuration in
            if !isRecording && newDuration == 0 {
                // 重置状态
                recordedDuration = 0
                hasRecorded = false
                isPressed = false
            }
        }
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct TextPanelView: View {
    @Binding var textContent: String
    @FocusState private var isTextEditorFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            TextEditor(text: $textContent)
                .font(.system(size: 15))
                .foregroundColor(Color(hex: "5a5a5a"))
                .lineSpacing(8)
                .scrollContentBackground(.hidden)
                .frame(height: 120)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "e5e7eb"), lineWidth: 1)
                        )
                )
                .focused($isTextEditorFocused)
            
            // 收回键盘按钮
            if isTextEditorFocused {
                HStack {
                    Spacer()
                    Button(action: {
                        isTextEditorFocused = false
                    }) {
                        Text("完成")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "f472b6"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.9))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color(hex: "f472b6").opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
                .padding(.top, 12)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isTextEditorFocused)
    }
}

struct ImagePanelView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var showImagePicker: Bool = false
    @State private var showActionSheet: Bool = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.selectedImages.isEmpty {
                // 空状态 - 显示添加按钮
                Button(action: { showActionSheet = true }) {
                    VStack(spacing: 16) {
                        Image(systemName: "plus")
                            .font(.system(size: 32))
                            .foregroundColor(Color(hex: "9ca3af"))

                        VStack(spacing: 4) {
                            Text("点击添加图片")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(hex: "6b7280"))
                            
                            Text("支持相册选择或拍照")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "9ca3af"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(
                                        Color(hex: "d1d5db"),
                                        style: StrokeStyle(lineWidth: 2, dash: [8])
                                    )
                            )
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Test button for debugging
                Button(action: { addTestImage() }) {
                    Text("添加测试图片")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "a78bfa"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .stroke(Color(hex: "a78bfa").opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            } else {
                // 已选择图片状态
                VStack(spacing: 12) {
                    // 图片网格
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                        ForEach(Array(viewModel.selectedImages.enumerated()), id: \.offset) { index, imageURL in
                            ImageThumbnailView(
                                imageURL: imageURL,
                                onRemove: {
                                    print("🗑️ [ImagePanel] Removing image at index \(index): \(imageURL.absoluteString)")
                                    viewModel.removeImage(at: index)
                                }
                            )
                        }
                        
                        // 添加更多图片按钮
                        if viewModel.selectedImages.count < 9 {
                            Button(action: { showActionSheet = true }) {
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(
                                        Color(hex: "a78bfa").opacity(0.3),
                                        style: StrokeStyle(lineWidth: 1, dash: [4])
                                    )
                                    .frame(height: 80)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .font(.system(size: 24))
                                            .foregroundColor(Color(hex: "a78bfa").opacity(0.6))
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    // 图片数量提示
                    HStack {
                        Text("已选择 \(viewModel.selectedImages.count) 张图片")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "8b8b8b"))
                        
                        Spacer()
                        
                        if viewModel.selectedImages.count >= 9 {
                            Text("最多9张")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "f5a5d1"))
                        }
                    }
                }
            }
        }
        .onAppear {
            print("🎯 [ImagePanel] Panel appeared with \(viewModel.selectedImages.count) images")
            for (index, url) in viewModel.selectedImages.enumerated() {
                print("🎯 [ImagePanel] Image \(index): \(url.absoluteString)")
                print("🎯 [ImagePanel] Image \(index) path: \(url.path)")
                print("🎯 [ImagePanel] Image \(index) file exists: \(FileManager.default.fileExists(atPath: url.path))")
            }
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("选择图片"),
                buttons: [
                    .default(Text("� 拍照")) {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            sourceType = .camera
                            showImagePicker = true
                        } else {
                            showToastMessage("相机不可用")
                        }
                    },
                    .default(Text("🖼️ 从相册选择")) {
                        sourceType = .photoLibrary
                        showImagePicker = true
                    },
                    .cancel(Text("取消"))
                ]
            )
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(
                sourceType: sourceType,
                onImageSelected: { image in
                    saveImageAndAddToSelection(image)
                }
            )
        }
        .toast(isShowing: $showToast, message: toastMessage)
    }
    
    private func saveImageAndAddToSelection(_ image: UIImage) {
        print("🖼️ [ImagePanel] Starting to save image...")
        
        // 保存图片到文档目录
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            print("❌ [ImagePanel] Failed to convert image to JPEG data")
            showToastMessage("图片处理失败")
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        print("🖼️ [ImagePanel] Documents path: \(documentsPath.path)")
        
        // 确保目录存在
        do {
            try FileManager.default.createDirectory(at: documentsPath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("❌ [ImagePanel] Failed to create directory: \(error)")
            showToastMessage("创建目录失败")
            return
        }
        
        let imageURL = documentsPath.appendingPathComponent("image_\(UUID().uuidString).jpg")
        print("🖼️ [ImagePanel] Saving image to: \(imageURL.absoluteString)")
        
        do {
            try imageData.write(to: imageURL)
            print("✅ [ImagePanel] Image saved successfully")
            
            // Verify file was created
            let fileExists = FileManager.default.fileExists(atPath: imageURL.path)
            print("🖼️ [ImagePanel] File exists after save: \(fileExists)")
            
            if fileExists {
                viewModel.addImage(imageURL)
                showToastMessage("图片已添加")
                print("✅ [ImagePanel] Image added to viewModel, total images: \(viewModel.selectedImages.count)")
            } else {
                print("❌ [ImagePanel] File was not created successfully")
                showToastMessage("图片保存验证失败")
            }
        } catch {
            print("❌ [ImagePanel] Failed to save image: \(error)")
            showToastMessage("图片保存失败: \(error.localizedDescription)")
        }
    }
    
    private func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        // 2秒后自动隐藏toast
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showToast = false
        }
    }
    
    private func addTestImage() {
        print("🧪 [ImagePanel] Creating test image...")
        let testImage = createTestImage()
        saveImageAndAddToSelection(testImage)
    }
    
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 300, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background gradient
            let colors = [UIColor(red: 0.65, green: 0.55, blue: 0.98, alpha: 1.0).cgColor,
                         UIColor(red: 0.96, green: 0.65, blue: 0.82, alpha: 1.0).cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
            context.cgContext.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: size.width, y: size.height), options: [])
            
            // Text
            let text = "测试图片"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 24, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(
                x: (size.width - textSize.width) / 2,
                y: (size.height - textSize.height) / 2,
                width: textSize.width,
                height: textSize.height
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}

// 图片缩略图视图
struct ImageThumbnailView: View {
    let imageURL: URL
    let onRemove: () -> Void
    @State private var image: UIImage?
    @State private var isLoading: Bool = true
    @State private var loadFailed: Bool = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(hex: "f5f5f5"))
                .frame(height: 80)
                .overlay(
                    Group {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                        } else if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(Color(hex: "a78bfa"))
                        } else {
                            VStack(spacing: 4) {
                                Image(systemName: loadFailed ? "exclamationmark.triangle" : "photo")
                                    .font(.system(size: 16))
                                    .foregroundColor(loadFailed ? Color(hex: "f5a5d1") : Color(hex: "b8b8b8"))
                                
                                if loadFailed {
                                    Text("加载失败")
                                        .font(.system(size: 8))
                                        .foregroundColor(Color(hex: "b8b8b8"))
                                }
                            }
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // 删除按钮
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.6))
                            .frame(width: 20, height: 20)
                    )
            }
            .offset(x: 6, y: -6)
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        print("🖼️ [RecordView] Loading image from: \(imageURL.absoluteString)")
        print("🖼️ [RecordView] File path: \(imageURL.path)")
        print("🖼️ [RecordView] URL scheme: \(imageURL.scheme ?? "no scheme")")
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                // Check if file exists
                let fileExists = FileManager.default.fileExists(atPath: imageURL.path)
                print("🖼️ [RecordView] File exists: \(fileExists)")
                
                guard fileExists else {
                    print("❌ [RecordView] Image file not found at path: \(imageURL.path)")
                    // List directory contents for debugging
                    let parentDir = imageURL.deletingLastPathComponent()
                    if let contents = try? FileManager.default.contentsOfDirectory(atPath: parentDir.path) {
                        print("📁 [RecordView] Directory contents: \(contents)")
                    }
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.loadFailed = true
                    }
                    return
                }
                
                print("✅ [RecordView] Image file exists, loading data...")
                let imageData = try Data(contentsOf: imageURL)
                print("✅ [RecordView] Image data loaded, size: \(imageData.count) bytes")
                
                if let uiImage = UIImage(data: imageData) {
                    print("✅ [RecordView] UIImage created successfully, size: \(uiImage.size)")
                    DispatchQueue.main.async {
                        self.image = uiImage
                        self.isLoading = false
                    }
                } else {
                    print("❌ [RecordView] Failed to create UIImage from data")
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.loadFailed = true
                    }
                }
            } catch {
                print("❌ [RecordView] Failed to load image from \(imageURL): \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.loadFailed = true
                }
            }
        }
    }
}

// UIImagePickerController 包装器
struct ImagePickerView: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    let onImageSelected: (UIImage) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        
        init(_ parent: ImagePickerView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImageSelected(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct TagsAreaView: View {
    let tags: [Tag]
    let selectedTags: Set<Tag>
    let onTagToggle: (Tag) -> Void

    @State private var showNewTagToast: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("添加标签")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "374151"))

                Spacer()

                Button(action: { showNewTagToast = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .semibold))
                        Text("新建")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Color(hex: "6b7280"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .stroke(Color(hex: "d1d5db"), lineWidth: 1)
                            .background(
                                Capsule()
                                    .fill(Color.white.opacity(0.8))
                            )
                    )
                }
            }

            FlowLayout(spacing: 12) {
                ForEach(tags) { tag in
                    TagItemView(
                        tag: tag,
                        isSelected: selectedTags.contains(tag)
                    ) {
                        onTagToggle(tag)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.8))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "e5e7eb"), lineWidth: 1)
                )
                .shadow(
                    color: Color.black.opacity(0.05),
                    radius: 8,
                    x: 0,
                    y: 2
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .toast(isShowing: $showNewTagToast, message: "新建标签功能开发中")
    }
}

// Flow Layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }

    struct FlowResult {
        var positions: [CGPoint] = []
        var size: CGSize = .zero

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var maxHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += maxHeight + spacing
                    maxHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                maxHeight = max(maxHeight, size.height)
                x += size.width + spacing
            }

            size = CGSize(width: maxWidth, height: y + maxHeight)
        }
    }
}

#Preview {
    RecordView(viewModel: AppViewModel())
}