//
//  AppViewModel.swift
//  Moment
//
//  应用视图模型 - 负责管理应用状态和导航
//

import Foundation
import SwiftUI
import SwiftData
import Combine
import AVFoundation

enum AppPage: String, CaseIterable {
    case home
    case record
    case list
    case settings
}

enum RecordTab: String, CaseIterable {
    case voice
    case text
    case image
}

struct FilterOption: Hashable {
    let text: String
    let imageName: String?
    let emotionName: String
}

@MainActor
class AppViewModel: NSObject, ObservableObject {
    // MARK: - SwiftData
    var modelContext: ModelContext?
    
    // MARK: - Navigation
    @Published var currentPage: AppPage = .home
    @Published var isShowingRecord: Bool = false

    // MARK: - Record Page
    @Published var selectedEmotion: Emotion?
    @Published var recordTab: RecordTab = .voice
    @Published var textContent: String = ""
    @Published var selectedTags: Set<Tag> = []
    @Published var isRecording: Bool = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var selectedImages: [URL] = []
    @Published var bookmarkURL: String = ""
    @Published var bookmarkTitle: String = ""

    // MARK: - Records
    @Published var records: [MoodRecord] = []
    @Published var selectedFilter: FilterOption = FilterOption(text: "全部", imageName: nil, emotionName: "全部")

    // MARK: - Settings
    @Published var isAppLockEnabled: Bool = false
    @Published var isDarkModeEnabled: Bool = false

    // MARK: - Tags
    @Published var availableTags: [Tag] = Tag.defaultTags

    // MARK: - Toast
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""

    // MARK: - Recording Timer
    private var recordingTimer: Timer?
    private var audioRecorder: AVAudioRecorder?
    private var currentRecordingURL: URL?

    var filterOptions: [FilterOption] {
        var options: [FilterOption] = [FilterOption(text: "全部", imageName: nil, emotionName: "全部")]
        options.append(contentsOf: Emotion.allEmotions.map { 
            FilterOption(text: $0.name, imageName: $0.imageName, emotionName: $0.name)
        })
        return options
    }

    var filteredRecords: [MoodRecord] {
        if selectedFilter.emotionName == "全部" {
            return records.sorted { $0.date > $1.date }
        }
        return records
            .filter { $0.emotionName == selectedFilter.emotionName }
            .sorted { $0.date > $1.date }
    }

    var canSave: Bool {
        !textContent.isEmpty || isRecording || recordingDuration > 0 || !selectedImages.isEmpty || selectedEmotion != nil
    }

    // MARK: - SwiftData Methods
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        migrateImagePaths() // Migrate old absolute paths to filenames
        fetchRecords()
    }
    
    // Migrate old absolute image paths to filenames
    private func migrateImagePaths() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<MoodRecord>()
        
        do {
            let allRecords = try context.fetch(descriptor)
            var needsSave = false
            
            for record in allRecords {
                var updatedImageStrings: [String] = []
                var hasChanges = false
                
                for imageString in record.imageURLStrings {
                    // Check if it's an absolute URL that needs migration
                    if imageString.contains("/Documents/") && imageString.contains("file://") {
                        // Extract filename from absolute path
                        if let url = URL(string: imageString) {
                            let filename = url.lastPathComponent
                            updatedImageStrings.append(filename)
                            hasChanges = true
                            print("🔄 Migrating image path: \(imageString) -> \(filename)")
                        } else {
                            updatedImageStrings.append(imageString)
                        }
                    } else {
                        // Already a filename or relative path, keep as is
                        updatedImageStrings.append(imageString)
                    }
                }
                
                if hasChanges {
                    record.imageURLStrings = updatedImageStrings
                    needsSave = true
                }
            }
            
            if needsSave {
                try context.save()
                print("✅ Image path migration completed")
            }
        } catch {
            print("❌ Failed to migrate image paths: \(error)")
        }
    }
    
    func fetchRecords() {
        guard let context = modelContext else { return }
        
        let descriptor = FetchDescriptor<MoodRecord>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        do {
            records = try context.fetch(descriptor)
        } catch {
            print("Failed to fetch records: \(error)")
        }
    }

    // MARK: - Image Management
    
    func addImage(_ imageURL: URL) {
        if selectedImages.count < 9 {
            selectedImages.append(imageURL)
            print("Image added successfully: \(imageURL.absoluteString)")
        } else {
            print("Cannot add image: maximum limit reached")
        }
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        let imageURL = selectedImages[index]
        selectedImages.remove(at: index)
        
        // 删除文件
        try? FileManager.default.removeItem(at: imageURL)
    }
    
    func clearImages() {
        // 删除所有图片文件
        for imageURL in selectedImages {
            try? FileManager.default.removeItem(at: imageURL)
        }
        selectedImages.removeAll()
    }
    
    // Helper function to convert URL to filename for storage
    private func getFilenameFromURL(_ url: URL) -> String {
        return url.lastPathComponent
    }
    // MARK: - Test Data (for debugging)
    
    func addTestRecord() {
        guard let context = modelContext else { return }
        
        // Create a test image in the documents directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = "test_image_\(UUID().uuidString).jpg"
        let testImageURL = documentsPath.appendingPathComponent(filename)
        
        // Create a simple test image
        let testImage = createTestImage()
        if let imageData = testImage.jpegData(compressionQuality: 0.8) {
            do {
                try imageData.write(to: testImageURL)
                print("✅ Test image created at: \(testImageURL.absoluteString)")
            } catch {
                print("❌ Failed to create test image: \(error)")
                return
            }
        }
        
        let testRecord = MoodRecord(
            emotionName: "开心",
            emotionEmoji: "😊",
            date: Date(),
            textContent: "这是一个测试记录，用来验证图片显示功能",
            imageURLStrings: [filename], // Store only filename
            tagNames: ["测试"],
            tagIcons: ["🧪"]
        )
        
        context.insert(testRecord)
        
        do {
            try context.save()
            fetchRecords()
            print("✅ Test record created successfully with filename: \(filename)")
        } catch {
            print("❌ Failed to save test record: \(error)")
        }
    }
    
    private func createTestImage() -> UIImage {
        let size = CGSize(width: 300, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background
            UIColor(red: 0.65, green: 0.55, blue: 0.98, alpha: 1.0).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Text
            let text = "Test Image"
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

    // MARK: - Actions
    
    func selectEmotion(_ emotion: Emotion) {
        selectedEmotion = emotion
        currentPage = .record
        isShowingRecord = true
    }

    func goHome() {
        currentPage = .home
        isShowingRecord = false
        resetRecordState()
    }

    func goToList() {
        currentPage = .list
        isShowingRecord = false
    }

    func goToSettings() {
        currentPage = .settings
        isShowingRecord = false
    }

    func switchTab(_ tab: RecordTab) {
        recordTab = tab
    }

    func toggleTag(_ tag: Tag) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            selectedTags.insert(tag)
        }
    }

    func startRecording() {
        // 请求录音权限
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self?.beginRecording()
                } else {
                    self?.showToastMessage("需要录音权限")
                }
            }
        }
    }
    
    private func beginRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            // 创建录音文件URL
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("recording_\(UUID().uuidString).m4a")
            currentRecordingURL = audioFilename
            
            // 录音设置
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            recordingDuration = 0
            recordingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.recordingDuration += 1
                }
            }
        } catch {
            showToastMessage("录音失败")
        }
    }

    func stopRecording() {
        isRecording = false
        recordingTimer?.invalidate()
        recordingTimer = nil
        audioRecorder?.stop()
        audioRecorder = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error)")
        }
    }

    func saveRecord() {
        guard let emotion = selectedEmotion, let context = modelContext else { 
            print("Cannot save record: missing emotion or context")
            return 
        }

        print("Saving record with \(selectedImages.count) images")
        
        // Convert URLs to filenames for storage
        let imageFilenames = selectedImages.map { getFilenameFromURL($0) }
        for (index, filename) in imageFilenames.enumerated() {
            print("Image \(index): \(filename)")
        }

        let record = MoodRecord(
            emotionName: emotion.name,
            emotionEmoji: emotion.emoji,
            date: Date(),
            textContent: textContent.isEmpty ? nil : textContent,
            voiceURLString: currentRecordingURL?.absoluteString,
            voiceDuration: recordingDuration > 0 ? recordingDuration : nil,
            imageURLStrings: imageFilenames, // Store filenames instead of full URLs
            bookmarkURLString: bookmarkURL.isEmpty ? nil : bookmarkURL,
            bookmarkTitle: bookmarkTitle.isEmpty ? nil : bookmarkTitle,
            tagNames: selectedTags.map { $0.name },
            tagIcons: selectedTags.map { $0.icon }
        )

        context.insert(record)
        
        do {
            try context.save()
            fetchRecords()
            showToastMessage("记录已保存")
            print("Record saved successfully with \(record.imageURLStrings.count) image filenames")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.goHome()
            }
        } catch {
            showToastMessage("保存失败: \(error.localizedDescription)")
            print("Failed to save record: \(error)")
        }
    }

    func resetRecordState() {
        selectedEmotion = nil
        recordTab = .voice
        textContent = ""
        selectedTags = []
        isRecording = false
        recordingDuration = 0
        clearImages() // Clear images and delete files
        bookmarkURL = ""
        bookmarkTitle = ""
        currentRecordingURL = nil
    }

    func showToastMessage(_ message: String) {
        toastMessage = message
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showToast = false
        }
    }
}

// MARK: - AVAudioRecorderDelegate
extension AppViewModel: AVAudioRecorderDelegate {
    nonisolated func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        Task { @MainActor in
            if !flag {
                showToastMessage("录音失败")
                currentRecordingURL = nil
            }
        }
    }
}