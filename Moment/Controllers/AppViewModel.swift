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
    @Published var selectedFilter: String = "全部"

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

    var filterOptions: [String] {
        var options = ["全部"]
        options.append(contentsOf: Emotion.allEmotions.map { "\($0.emoji) \($0.name)" })
        return options
    }

    var filteredRecords: [MoodRecord] {
        if selectedFilter == "全部" {
            return records.sorted { $0.date > $1.date }
        }
        let emotionName = selectedFilter.components(separatedBy: " ").last ?? ""
        return records
            .filter { $0.emotionName == emotionName }
            .sorted { $0.date > $1.date }
    }

    var canSave: Bool {
        !textContent.isEmpty || isRecording || recordingDuration > 0 || selectedEmotion != nil
    }

    // MARK: - SwiftData Methods
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        fetchRecords()
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
        guard let emotion = selectedEmotion, let context = modelContext else { return }

        let record = MoodRecord(
            emotionName: emotion.name,
            emotionEmoji: emotion.emoji,
            date: Date(),
            textContent: textContent.isEmpty ? nil : textContent,
            voiceURLString: currentRecordingURL?.absoluteString,
            voiceDuration: recordingDuration > 0 ? recordingDuration : nil,
            imageURLStrings: selectedImages.map { $0.absoluteString },
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.goHome()
            }
        } catch {
            showToastMessage("保存失败")
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
        selectedImages = []
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

    func getEmotionFromFilter(_ filter: String) -> String {
        if filter == "全部" { return "全部" }
        return filter.components(separatedBy: " ").last ?? filter
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