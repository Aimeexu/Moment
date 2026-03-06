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
            // Background
            BackgroundDecorations()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                RecordHeaderView(
                    onBack: { viewModel.goHome() },
                    onSave: { viewModel.saveRecord() },
                    canSave: !viewModel.textContent.isEmpty || viewModel.isRecording || viewModel.recordingDuration > 0
                )

                // Emotion Show
                if let emotion = viewModel.selectedEmotion {
                    VStack(spacing: 20) {
                        // Icon
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "a78bfa").opacity(0.15),
                                        Color(hex: "f5a5d1").opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text(emotion.emoji)
                                    .font(.system(size: 50))
                            )
                            .shadow(
                                color: Color(hex: "a78bfa").opacity(0.12),
                                radius: 12,
                                x: 0,
                                y: 8
                            )

                        // Label
                        Text(emotion.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "a78bfa"))
                            .padding(.horizontal, 28)
                            .padding(.vertical, 12)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "a78bfa").opacity(0.1))
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color(hex: "a78bfa").opacity(0.3), lineWidth: 1)
                            )
                    }
                    .padding(.vertical, 40)
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

                Spacer(minLength: 80)
            }
        }
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .leading)),
            removal: .opacity.combined(with: .move(edge: .trailing))
        ))
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
                HStack(spacing: 0) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                }
                .frame(width: 40, height: 40)
                .background(Color(hex: "a78bfa").opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundColor(Color(hex: "a78bfa"))
            }

            Spacer()

            Text("记录你的心情时刻")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(hex: "5a5a5a"))

            Spacer()

            // Save Button
            Button(action: onSave) {
                Text("保存")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "a78bfa"), Color(hex: "f5a5d1")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .opacity(canSave ? 1 : 0.5)
            }
            .disabled(!canSave)
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
        .padding(.bottom, 16)
        .background(
            Rectangle()
                .fill(Color.white.opacity(0.95))
                .background(.ultraThinMaterial)
        )
    }
}

struct RecordTabsView: View {
    let selectedTab: RecordTab
    let onSelect: (RecordTab) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(RecordTab.allCases, id: \.self) { tab in
                Button(action: { onSelect(tab) }) {
                    Text(tabTitle(for: tab))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(selectedTab == tab ? Color(hex: "a78bfa") : Color(hex: "b8b8b8"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            VStack {
                                Spacer()
                                if selectedTab == tab {
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Color(hex: "a78bfa"), Color(hex: "f5a5d1")],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(height: 2)
                                        .clipShape(Capsule())
                                }
                            }
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private func tabTitle(for tab: RecordTab) -> String {
        switch tab {
        case .voice: return "🎵 语音"
        case .text: return "✍️ 文字"
        case .image: return "🖼️ 图片"
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
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "a78bfa").opacity(0.06),
                            Color(hex: "f5a5d1").opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(hex: "a78bfa").opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 20)
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
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "f5a5d1"), Color(hex: "f08080")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(
                        color: Color(hex: "f5a5d1").opacity(isRecording ? 0.35 : 0.25),
                        radius: isRecording ? 16 : 12,
                        x: 0,
                        y: isRecording ? 16 : 8
                    )

                Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .scaleEffect(isRecording || isPressed ? 1.1 : 1.0)
            .animation(
                .spring(response: 0.3, dampingFraction: 0.6),
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
                    Text("录音中...")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "8b8b8b"))
                    
                    Text(formattedDuration(duration))
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(Color(hex: "a78bfa"))
                        .tracking(2)
                }
            } else if hasRecorded && recordedDuration > 0 {
                VStack(spacing: 8) {
                    Text("录音完成")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "5a5a5a"))
                    
                    HStack(spacing: 6) {
                        Image(systemName: "waveform")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "a78bfa"))
                        
                        Text(formattedDuration(recordedDuration))
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color(hex: "a78bfa"))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(hex: "a78bfa").opacity(0.1))
                    )
                }
            } else {
                Text("长按开始录音")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(hex: "8b8b8b"))
            }
        }
        .padding(.vertical, 24)
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
                .frame(height: 150)
                .padding(.horizontal, 4)
                .padding(.vertical, 8)
                .background(Color.clear)
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
                            .foregroundColor(Color(hex: "a78bfa"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "a78bfa").opacity(0.1))
                            )
                    }
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isTextEditorFocused)
    }
}

struct ImagePanelView: View {
    @ObservedObject var viewModel: AppViewModel
    @State private var showToast: Bool = false
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
                            .font(.system(size: 48))
                            .foregroundColor(Color(hex: "a7e4d0"))

                        VStack(spacing: 4) {
                            Text("点击添加图片")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "8b8b8b"))
                            
                            Text("支持相册选择或拍照")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "b8b8b8"))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 50)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(
                                Color(hex: "a78bfa").opacity(0.3),
                                style: StrokeStyle(lineWidth: 2, dash: [8])
                            )
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
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("选择图片"),
                buttons: [
                    .default(Text("📷 拍照")) {
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
        .toast(isShowing: $showToast, message: "图片已添加")
    }
    
    private func saveImageAndAddToSelection(_ image: UIImage) {
        // 保存图片到文档目录
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            showToastMessage("图片处理失败")
            return
        }
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imageURL = documentsPath.appendingPathComponent("image_\(UUID().uuidString).jpg")
        
        do {
            try imageData.write(to: imageURL)
            viewModel.addImage(imageURL)
            showToastMessage("图片已添加")
        } catch {
            print("Failed to save image: \(error)")
            showToastMessage("图片保存失败")
        }
    }
    
    private func showToastMessage(_ message: String) {
        // 这里可以通过viewModel显示toast，或者使用本地状态
        // 为了简化，我们使用本地toast状态
        showToast = true
    }
}

// 图片缩略图视图
struct ImageThumbnailView: View {
    let imageURL: URL
    let onRemove: () -> Void
    @State private var image: UIImage?
    
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
                        } else {
                            ProgressView()
                                .scaleEffect(0.8)
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
        DispatchQueue.global(qos: .userInitiated).async {
            if let imageData = try? Data(contentsOf: imageURL),
               let uiImage = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.image = uiImage
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
        VStack(spacing: 14) {
            HStack {
                Text("添加标签")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(Color(hex: "5a5a5a"))

                Spacer()

                Button(action: { showNewTagToast = true }) {
                    Text("+ 新建")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "a78bfa"), Color(hex: "f5a5d1")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                }
            }

            FlowLayout(spacing: 10) {
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
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "a78bfa").opacity(0.06),
                            Color(hex: "f5a5d1").opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(hex: "a78bfa").opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 20)
        .toast(isShowing: $showNewTagToast, message: "新建标签")
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