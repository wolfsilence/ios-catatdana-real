import SwiftUI
import PhotosUI
import CoreLocation

//
//  CDRecordTransactionView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDRecordView: View {
    let onBack: () -> Void
    let onSaved: () -> Void

    @State private var vm = CDRecordViewModel()
    @State private var showCamera = false
    @State private var showGallery = false
    @State private var showPhotoAction = false
    @State private var capturedImage: UIImage? = nil
    @State private var isLocating = false
    @State private var showSavedToast = false

    var body: some View {
        VStack(spacing: 0) {
            pageHeader

            ScrollView {
                VStack(spacing: 16) {
                    typeToggle
                    amountInput
                    categoryGrid
                    locationAndNote
                    photoSection
                    saveButton
                }
                .padding(20)
            }
        }
        .background(AppColors.launchBackground)
        .toast(isPresented: $showSavedToast, message: AllStr.rtSt)
        .onAppear { detectLocation() }
        .fullScreenCover(isPresented: $showCamera) {
            RecordCameraView { image in
                capturedImage = image
                uploadCapturedImage()
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
                        await MainActor.run {
                            capturedImage = image
                            uploadCapturedImage()
                        }
                    }
                }
            }
        ), matching: .images)
        .confirmationDialog(AllStr.rtPt, isPresented: $showPhotoAction) {
            Button(AllStr.pfTp) { showCamera = true }
            Button(AllStr.pfPg) { showGallery = true }
            Button(AllStr.cmC, role: .cancel) { }
        }
    }

    // MARK: - Header

    private var pageHeader: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                ZStack {
                    Circle().fill(AppColors.launchBackground).frame(width: 36, height: 36)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.strPrimary)
                }
            }
            Text(AllStr.rtT)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.strPrimary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.white)
    }

    // MARK: - Type Toggle

    private var typeToggle: some View {
        HStack(spacing: 0) {
            ForEach(TransactionType.allCases, id: \.self) { t in
                Button {
                    vm.type = t
                } label: {
                    Text(t == .expense ? AllStr.cmE : AllStr.cmI)
                        .font(.system(size: 14, weight: vm.type == t ? .semibold : .regular))
                        .foregroundColor(vm.type == t ? .white : AppColors.strSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            vm.type == t
                                ? (t == .expense ? Color(hex: "#FF9500") : AppColors.primary)
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(4)
        .background(AppColors.launchBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Amount Input

    private var amountInput: some View {
        VStack(spacing: 8) {
            Text(AllStr.cmA)
                .font(.system(size: 13))
                .foregroundColor(AppColors.strSecondary)
            HStack(spacing: 8) {
                Text("Rp")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppColors.strHint)
                TextField("0", text: $vm.amount)
                    .keyboardType(.numberPad)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(vm.type == .income ? AppColors.primary : AppColors.strPrimary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

    // MARK: - Category Grid

    private var categoryGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(AllStr.rtC)
                .font(.system(size: 13))
                .foregroundColor(AppColors.strSecondary)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(TransactionCategory.categories(for: vm.type)) { cat in
                    Button {
                        vm.category = cat.id
                    } label: {
                        VStack(spacing: 4) {
                            Text(cat.icon).font(.system(size: 20))
                            Text(cat.label)
                                .font(.system(size: 10, weight: vm.category == cat.id ? .semibold : .regular))
                                .foregroundColor(vm.category == cat.id ? AppColors.primary : AppColors.strSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(vm.category == cat.id ? Color(hex: "#E8F8EE") : AppColors.launchBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(vm.category == cat.id ? AppColors.primary : Color.clear, lineWidth: 1.5)
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

    // MARK: - Location & Note

    private var locationAndNote: some View {
        VStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(AllStr.cmL)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.strSecondary)
                    Spacer()
                    if isLocating {
                        ProgressView().scaleEffect(0.7)
                    } else {
                        Button {
                            detectLocation()
                        } label: {
                            Image(systemName: "location.fill.viewfinder")
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.primary)
                    TextField(AllStr.rtLp, text: $vm.location)
                        .font(.system(size: 14))
                }
                .padding(12)
                .background(AppColors.launchBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(AllStr.cmN)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(AppColors.strSecondary)
                TextField(AllStr.rtNp, text: $vm.note, axis: .vertical)
                    .font(.system(size: 14))
                    .padding(12)
                    .background(AppColors.launchBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .lineLimit(3...6)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

    // MARK: - Photo

    private var photoSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(AllStr.rtPt)
                .font(.system(size: 13))
                .foregroundColor(AppColors.strSecondary)

            if let image = capturedImage {
                ZStack(alignment: .topTrailing) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    Button {
                        capturedImage = nil
                        vm.photoPath = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.white)
                            .background(Circle().fill(Color.black.opacity(0.4)))
                    }
                    .padding(8)
                }
            } else if !vm.photoPath.isEmpty {
                HStack {
                    Image(systemName: "photo.fill")
                        .foregroundColor(AppColors.primary)
                    Text(AllStr.rtPa)
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.strPrimary)
                    Spacer()
                    Button { vm.photoPath = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.strHint)
                    }
                }
                .padding(12)
                .background(AppColors.launchBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Button {
                    showPhotoAction = true
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppColors.primary)
                        Text(AllStr.rtTp)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(AppColors.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(AppColors.launchBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                            .foregroundColor(Color.black.opacity(0.1))
                    )
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button {
            Task { await vm.save() }
        } label: {
            Text(vm.saved ? "✓ \(AllStr.cmSd)" : AllStr.rtS)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(vm.saved ? Color(hex: "#13A048") : AppColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .disabled(!vm.isValid || vm.isSaving)
        .opacity(vm.isValid ? 1 : 0.6)
        .onChange(of: vm.saved) { _, saved in
            if saved {
                onSaved()
                showSavedToast = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    onBack()
                }
            }
        }
    }

    // MARK: - Location

    private func detectLocation() {
        isLocating = true
        LocationManager.shared.requestLocation { location in
            guard let location else {
                isLocating = false
                return
            }
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
                isLocating = false
                guard let place = placemarks?.first else { return }
                let parts = [
                    place.name,
                    place.locality,
                    place.administrativeArea,
                    place.country
                ].compactMap { $0 }
                let address = parts.joined(separator: ", ")
                if !address.isEmpty {
                    vm.location = address
                }
            }
        }
    }

    // MARK: - Image Upload

    private func uploadCapturedImage() {
        guard let image = capturedImage,
              let compressed = ImageCompressor.compress(image) else { return }
        Task.detached(priority: .userInitiated) {
            let result: NetResp<Entity11> = await Net.shared.uploadImage(
                path: Paths.kewhbt,
                rawBody: compressed
            )
            guard result.isSuccess, let url = result.data?.jjxdyyege, !url.isEmpty else { return }
            await MainActor.run {
                vm.photoPath = url
            }
        }
    }
}

// MARK: - Camera View

private struct RecordCameraView: UIViewControllerRepresentable {
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
