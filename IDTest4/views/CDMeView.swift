import SwiftUI
import PhotosUI
import StoreKit

//
//  CDProfileView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDMeView: View {
    let onSettings: () -> Void
    let onPrivacy: () -> Void
    let onContact: () -> Void
    let onLogout: () -> Void
    let transactionsCount: Int
    let cardsCount: Int
    let remindersCount: Int
    let userName: String
    let userPhone: String
    let userInitial: String
    let avatarURL: String
    let onAvatarChanged: (String) -> Void
    let onNicknameChanged: (String) -> Void

    @State private var showAvatarSheet = false
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var showNameAlert = false
    @State private var nameInput = ""
    @State private var localNickname: String = ""

    var displayName: String {
        !localNickname.isEmpty ? localNickname : userName
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                illustrationHeader
                avatarAndInfo
                statsBar
                menuSection
            }
        }
        .padding(.top, 8)
        .onAppear {
            localNickname = UserDefaults.standard.string(forKey: K.profileNicknameK) ?? ""
        }
        // Camera
        .fullScreenCover(isPresented: $showCamera) {
            CameraView { image in
                handleCapturedImage(image)
            }
            .ignoresSafeArea()
        }
        // Gallery
        .photosPicker(isPresented: $showGallery, selection: Binding<PhotosPickerItem?>(
            get: { nil },
            set: { item in
                guard let item else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await MainActor.run { handleCapturedImage(image) }
                    }
                }
            }
        ), matching: .images)
        // Name alert
        .alert(AllStr.pfCn, isPresented: $showNameAlert) {
            TextField(AllStr.pfNp, text: $nameInput)
            Button(AllStr.cmC, role: .cancel) { }
            Button(AllStr.cmS) {
                let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty {
                    localNickname = trimmed
                    onNicknameChanged(trimmed)
                }
            }
        } message: {
            Text(AllStr.pfNm)
        }
    }

    // MARK: - Header Illustration

    private var illustrationHeader: some View {
        VStack(spacing: 0) {
            ZStack {
                Ellipse()
                    .fill(Color(hex: "#1BC459").opacity(0.1))
                    .frame(width: 160, height: 40)
                    .offset(y: 50)

                HStack(alignment: .bottom, spacing: 12) {
                    VStack(spacing: -12) {
                        Circle().fill(Color(hex: "#E8F8EE")).frame(width: 40, height: 40)
                            .overlay(Text("Rp").font(.system(size: 10, weight: .bold)).foregroundColor(AppColors.primary))
                        Circle().fill(Color(hex: "#1BC459").opacity(0.5)).frame(width: 40, height: 40)
                        Circle().fill(AppColors.primary).frame(width: 40, height: 40)
                    }

                    VStack(spacing: 0) {
                        Circle().fill(Color(hex: "#FFD6B0")).frame(width: 32, height: 32)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColors.primary)
                            .frame(width: 32, height: 36)
                    }

                    ZStack {
                        Circle().stroke(Color(hex: "#E5E7EB"), lineWidth: 1).frame(width: 50, height: 50)
                        Circle().fill(AppColors.primary).frame(width: 22, height: 22)
                    }
                    .offset(y: -10)
                }
                .offset(y: -20)
            }
            .frame(height: 120)
        }
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [Color(hex: "#E8F8EE"), AppColors.launchBackground],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    // MARK: - Avatar

    private var avatarAndInfo: some View {
        VStack(spacing: 8) {
            Button { showAvatarSheet = true } label: {
                ZStack {
                    if let url = URL(string: avatarURL), !avatarURL.isEmpty {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image.resizable().scaledToFill()
                            default:
                                avatarInitialView
                            }
                        }
                        .frame(width: 64, height: 64)
                        .clipShape(Circle())
                    } else {
                        avatarInitialView
                    }
                }
                .frame(width: 64, height: 64)
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                .shadow(color: AppColors.primary.opacity(0.3), radius: 4, y: 2)
                .overlay(alignment: .bottomTrailing) {
                    ZStack {
                        Circle().fill(Color.white).frame(width: 22, height: 22)
                        Circle().fill(AppColors.primary).frame(width: 18, height: 18)
                        Image(systemName: "camera.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.white)
                    }
                    .offset(x: 2, y: 2)
                }
            }
            .offset(y: -32)
            .padding(.bottom, -32)
            .confirmationDialog(AllStr.pfAt, isPresented: $showAvatarSheet) {
                Button(AllStr.pfTp) { showCamera = true }
                Button(AllStr.pfPg) { showGallery = true }
                Button(AllStr.cmC, role: .cancel) { }
            }

            // Name — clickable to edit
            Button { nameInput = displayName; showNameAlert = true } label: {
                HStack(spacing: 4) {
                    Text(displayName)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(AppColors.strPrimary)
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.strHint)
                }
            }

            Text(userPhone)
                .font(.system(size: 13))
                .foregroundColor(AppColors.strSecondary)
        }
    }

    private var avatarInitialView: some View {
        Circle()
            .fill(LinearGradient(
                colors: [Color(hex: "#1BC459"), Color(hex: "#13A048")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .overlay(
                Text(userInitial)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            )
    }

    // MARK: - Image Upload

    private func handleCapturedImage(_ image: UIImage) {
        guard let compressed = ImageCompressor.compress(image) else { return }
        Task.detached(priority: .userInitiated) {
            let result: NetResp<Entity11> = await Net.shared.uploadImage(
                path: Paths.kewhbt,
                rawBody: compressed
            )
            guard result.isSuccess, let url = result.data?.jjxdyyege, !url.isEmpty else { return }
            await MainActor.run {
                onAvatarChanged(url)
            }
        }
    }

    // MARK: - Stats

    private var statsBar: some View {
        HStack(spacing: 0) {
            statItem("\(transactionsCount)", AllStr.pfTr)
            Rectangle().fill(Color.black.opacity(0.06)).frame(width: 1, height: 32)
            statItem("\(cardsCount)", AllStr.pfCc)
            Rectangle().fill(Color.black.opacity(0.06)).frame(width: 1, height: 32)
            statItem("\(remindersCount)", AllStr.pfRm)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private func statItem(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primary)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(AppColors.strSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Menu

    private var menuSection: some View {
        VStack(spacing: 0) {
            menuItem(
                label: AllStr.pfCu,
                icon: "bubble.left.fill",
                iconBg: Color(hex: "#EFF6FF"),
                iconColor: Color(hex: "#3B82F6"),
                action: onContact
            )
            Divider().padding(.leading, 56)
            menuItem(
                label: AllStr.pfPr,
                icon: "lock.shield.fill",
                iconBg: Color(hex: "#E8F8EE"),
                iconColor: AppColors.primary,
                action: onPrivacy
            )
            Divider().padding(.leading, 56)
            menuItem(
                label: AllStr.pfRa,
                icon: "star.fill",
                iconBg: Color(hex: "#FEF3C7"),
                iconColor: Color(hex: "#F59E0B"),
                action: {
                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                }
            )
            Divider().padding(.leading, 56)
            menuItem(
                label: AllStr.pfSe,
                icon: "gearshape.fill",
                iconBg: Color(hex: "#EDE9FE"),
                iconColor: Color(hex: "#8B5CF6"),
                action: onSettings
            )
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private func menuItem(label: String, icon: String, iconBg: Color, iconColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(iconBg)
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(iconColor)
                }
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(AppColors.strPrimary)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColors.strHint)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
    }

}

// MARK: - Camera View (UIImagePickerController wrapper)

private struct CameraView: UIViewControllerRepresentable {
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
