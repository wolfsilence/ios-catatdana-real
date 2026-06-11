import SwiftUI
import PhotosUI
import AVFoundation
import AVKit
import CoreTransferable

//
//  CDContactView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDContactView: View {
    let onBack: () -> Void

    @State private var message: String = ""
    @State private var contactInfo: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var showImageSheet = false
    @State private var showVideoCamera = false
    @State private var showVideoGallery = false
    @State private var showVideoSheet = false
    @State private var selectedVideoURL: URL? = nil
    @State private var videoThumbnail: UIImage? = nil
    @State private var videoPickerItem: PhotosPickerItem?
    @State private var showVideoPlayer = false
    @State private var isSubmitting = false
    @State private var showSuccess = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Button(action: onBack) {
                    ZStack {
                        Circle().fill(Colors.launchBackground).frame(width: 36, height: 36)
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Colors.textPrimary)
                    }
                }
                Text(Strings.Contact.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Colors.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 12)
            .background(Color.white)

            ScrollView {
                VStack(spacing: 20) {
                    // Large message input
                    VStack(alignment: .leading, spacing: 6) {
                        Text(Strings.Contact.messageLabel)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Colors.textSecondary)
                        TextEditor(text: $message)
                            .font(.system(size: 14))
                            .frame(minHeight: 160)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black.opacity(0.06), lineWidth: 1.5)
                            )
                            .scrollContentBackground(.hidden)
                    }

                    // Image section
                    VStack(alignment: .leading, spacing: 6) {
                        Text(Strings.Contact.attachmentLabel)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Colors.textSecondary)

                        if let image = selectedImage {
                            ZStack(alignment: .topTrailing) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 160)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                Button {
                                    selectedImage = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.black.opacity(0.4)))
                                }
                                .padding(8)
                            }
                        } else {
                            Button { showImageSheet = true } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 24))
                                        .foregroundColor(Colors.primary)
                                    Text(Strings.Contact.addImage)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Colors.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                                        .foregroundColor(Color.black.opacity(0.1))
                                )
                            }
                        }
                    }

                    // Video section
                    VStack(alignment: .leading, spacing: 6) {
                        Text(Strings.Contact.videoLabel)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Colors.textSecondary)

                        if let url = selectedVideoURL {
                            ZStack(alignment: .topTrailing) {
                                // 缩略图 + 播放按钮
                                Button {
                                    showVideoPlayer = true
                                } label: {
                                    ZStack {
                                        if let thumb = videoThumbnail {
                                            Image(uiImage: thumb)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 160)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        } else {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.black.opacity(0.05))
                                                .frame(height: 160)
                                        }
                                        // 播放按钮
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 44))
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                                    }
                                }

                                Button {
                                    selectedVideoURL = nil
                                    videoThumbnail = nil
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                        .background(Circle().fill(Color.black.opacity(0.4)))
                                }
                                .padding(8)
                            }
                        } else {
                            Button { showVideoSheet = true } label: {
                                VStack(spacing: 8) {
                                    Image(systemName: "video.badge.plus")
                                        .font(.system(size: 24))
                                        .foregroundColor(Colors.primary)
                                    Text(Strings.Contact.addVideo)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(Colors.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 100)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                                        .foregroundColor(Color.black.opacity(0.1))
                                )
                            }
                        }
                    }

                    // Contact info input (required)
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 2) {
                            Text(Strings.Contact.contactLabel)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Colors.textSecondary)
                            Text("*")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.red)
                        }
                        TextField(Strings.Contact.contactPlaceholder, text: $contactInfo)
                            .keyboardType(.emailAddress)
                            .font(.system(size: 14))
                            .padding(12)
                            .frame(height: 48)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black.opacity(0.06), lineWidth: 1.5)
                            )
                    }

                    // Submit button
                    Button {
                        Task { await submit() }
                    } label: {
                        HStack(spacing: 8) {
                            if isSubmitting {
                                ProgressView().tint(.white)
                            }
                            Text(isSubmitting ? Strings.Contact.submitting : Strings.Contact.submit)
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(canSubmit ? Colors.primary : Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .disabled(!canSubmit || isSubmitting)
                }
                .padding(20)
            }
        }
        .background(Colors.launchBackground)
        .confirmationDialog(Strings.Contact.attachmentSheet, isPresented: $showImageSheet) {
            Button(Strings.Profile.takePhoto) { showCamera = true }
            Button(Strings.Profile.pickGallery) { showGallery = true }
            Button(Strings.Common.cancel, role: .cancel) { }
        }
        .fullScreenCover(isPresented: $showCamera) {
            ContactCameraView { image in
                selectedImage = image
            }
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showVideoCamera) {
            ContactVideoCameraView { url in
                handleVideoPicked(url: url)
            }
            .ignoresSafeArea()
        }
        .photosPicker(isPresented: $showGallery, selection: Binding<PhotosPickerItem?>(
            get: { nil },
            set: { item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run { selectedImage = image }
                    }
                }
            }
        ), matching: .images)
        .confirmationDialog(Strings.Contact.videoSheet, isPresented: $showVideoSheet) {
            Button(Strings.Contact.recordVideo) { showVideoCamera = true }
            Button(Strings.Contact.pickVideo) { showVideoGallery = true }
            Button(Strings.Common.cancel, role: .cancel) { }
        }
        .photosPicker(isPresented: $showVideoGallery, selection: $videoPickerItem, matching: .videos)
        .onChange(of: videoPickerItem) { _, item in
            guard let item else { return }
            Task {
                if let movie = try? await item.loadTransferable(type: Movie.self) {
                    await MainActor.run { handleVideoPicked(url: movie.url) }
                }
            }
        }
        .fullScreenCover(isPresented: $showVideoPlayer) {
            if let url = selectedVideoURL {
                let player = AVPlayer(url: url)
                VideoPlayer(player: player)
                    .ignoresSafeArea()
                    .onAppear { player.play() }
                    .onDisappear { player.pause() }
                    .overlay(alignment: .topTrailing) {
                        Button {
                            showVideoPlayer = false
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.5), radius: 4)
                        }
                        .padding(20)
                    }
            }
        }
        .overlay {
            if showSuccess {
                successToast
            }
        }
    }

    private var canSubmit: Bool {
        !message.trimmingCharacters(in: .whitespaces).isEmpty
        && !contactInfo.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func submit() async {
        isSubmitting = true

        // Upload image if present
        var imageUrl: String? = nil
        if let image = selectedImage,
           let compressed = ImageCompressor.compress(image) {
            let result: NetResponse<nsevfhu> = await Net.shared.uploadImage(
                path: NetPath.kewhbt,
                rawBody: compressed
            )
            if result.isSuccess {
                imageUrl = result.data?.jjxdyyege
            }
        }

        // Upload video if present
        var videoUrl: String? = nil
        if let videoURL = selectedVideoURL,
           let compressedURL = await VideoCompressor.compress(inputURL: videoURL),
           let videoData = try? Data(contentsOf: compressedURL) {
            let result: NetResponse<nsevfhu> = await Net.shared.uploadImage(
                path: NetPath.kewhbt,
                rawBody: videoData
            )
            if result.isSuccess {
                videoUrl = result.data?.jjxdyyege
            }
            // 清理压缩临时文件
            try? FileManager.default.removeItem(at: compressedURL)
        }

        // Submit via anyBiz
        var data: [String: String] = [
            "action": "contact",
            "message": message,
            "contact": contactInfo,
        ]
        if let url = imageUrl { data["imageUrl"] = url }
        if let url = videoUrl { data["videoUrl"] = url }

        let req = uoz(pclb: "contact", qkipkeyov: data)
        let _: NetResponse<EmptyResp> = await Net.shared.post(
            path: NetPath.halkm,
            encodableBody: req
        )

        isSubmitting = false
        showSuccess = true

        try? await Task.sleep(nanoseconds: 1_500_000_000)
        onBack()
    }

    // MARK: - Video Helper

    private func handleVideoPicked(url: URL) {
        selectedVideoURL = url
        videoThumbnail = VideoCompressor.generateThumbnail(url: url)
    }

    // MARK: - Success Toast

    private var successToast: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 40))
                .foregroundColor(Colors.primary)
            Text(Strings.Contact.successMessage)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Colors.textPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.15), radius: 10, y: 4)
        .padding(.horizontal, 40)
        .transition(.scale.combined(with: .opacity))
        .animation(.easeInOut, value: showSuccess)
    }
}

// MARK: - Contact Camera View

private struct ContactCameraView: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (UIImage) -> Void
        let dismiss: DismissAction

        init(onCapture: @escaping (UIImage) -> Void, dismiss: DismissAction) {
            self.onCapture = onCapture
            self.dismiss = dismiss
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onCapture(image)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}

// MARK: - Contact Video Camera View

private struct ContactVideoCameraView: UIViewControllerRepresentable {
    let onCapture: (URL) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeMedium
        picker.videoMaximumDuration = 30
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture, dismiss: dismiss)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onCapture: (URL) -> Void
        let dismiss: DismissAction

        init(onCapture: @escaping (URL) -> Void, dismiss: DismissAction) {
            self.onCapture = onCapture
            self.dismiss = dismiss
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let url = info[.mediaURL] as? URL {
                onCapture(url)
            }
            dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}

// MARK: - Video Transferable (PhotosPicker 用)

private struct Movie: Transferable {
    let url: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { movie in
            SentTransferredFile(movie.url)
        } importing: { received in
            let copy = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent(UUID().uuidString + ".mp4")
            try FileManager.default.copyItem(at: received.file, to: copy)
            return Self(url: copy)
        }
    }
}
