import SwiftUI
import PhotosUI

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

                    // Contact info input
                    VStack(alignment: .leading, spacing: 6) {
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
        .overlay {
            if showSuccess {
                successToast
            }
        }
    }

    private var canSubmit: Bool {
        !message.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func submit() async {
        isSubmitting = true

        // Upload image if present
        var imageUrl: String? = nil
        if let image = selectedImage,
           let compressed = ImageCompressor.compress(image) {
            let result: NetResponse<nsevfhu> = await Net.shared.uploadImage(
                path: NetPath.ossUpload,
                rawBody: compressed
            )
            if result.isSuccess {
                imageUrl = result.data?.jjxdyyege
            }
        }

        // Submit via anyBiz
        var data: [String: String] = [
            "action": "contact",
            "message": message,
            "contact": contactInfo,
        ]
        if let url = imageUrl { data["imageUrl"] = url }

        let req = uoz(pclb: "contact", qkipkeyov: data)
        let _: NetResponse<EmptyResp> = await Net.shared.post(
            path: NetPath.anyBiz,
            encodableBody: req
        )

        isSubmitting = false
        showSuccess = true

        try? await Task.sleep(nanoseconds: 1_500_000_000)
        onBack()
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
