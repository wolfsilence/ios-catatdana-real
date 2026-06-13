import SwiftUI
import PhotosUI
import CoreLocation

//
//  CDRecordTransactionView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/7.
//

struct CDRecordTransactionView: View {
    let onBack: () -> Void
    let onSaved: () -> Void

    @State private var vm = TransactionViewModel()
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
        .background(Colors.launchBackground)
        .toast(isPresented: $showSavedToast, message: AllStr.RecordTransaction.savedToast)
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
        .confirmationDialog(AllStr.RecordTransaction.photoTitle, isPresented: $showPhotoAction) {
            Button(AllStr.Profile.takePhoto) { showCamera = true }
            Button(AllStr.Profile.pickGallery) { showGallery = true }
            Button(AllStr.Common.cancel, role: .cancel) { }
        }
    }

    // MARK: - Header

    private var pageHeader: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                ZStack {
                    Circle().fill(Colors.launchBackground).frame(width: 36, height: 36)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Colors.textPrimary)
                }
            }
            Text(AllStr.RecordTransaction.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Colors.textPrimary)
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
                    Text(t == .expense ? AllStr.Common.expense : AllStr.Common.income)
                        .font(.system(size: 14, weight: vm.type == t ? .semibold : .regular))
                        .foregroundColor(vm.type == t ? .white : Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            vm.type == t
                                ? (t == .expense ? Color(hex: "#FF9500") : Colors.primary)
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(4)
        .background(Colors.launchBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Amount Input

    private var amountInput: some View {
        VStack(spacing: 8) {
            Text(AllStr.Common.amount)
                .font(.system(size: 13))
                .foregroundColor(Colors.textSecondary)
            HStack(spacing: 8) {
                Text("Rp")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(Colors.textHint)
                TextField("0", text: $vm.amount)
                    .keyboardType(.numberPad)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(vm.type == .income ? Colors.primary : Colors.textPrimary)
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
            Text(AllStr.RecordTransaction.category)
                .font(.system(size: 13))
                .foregroundColor(Colors.textSecondary)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(TransactionCategory.categories(for: vm.type)) { cat in
                    Button {
                        vm.category = cat.id
                    } label: {
                        VStack(spacing: 4) {
                            Text(cat.icon).font(.system(size: 20))
                            Text(cat.label)
                                .font(.system(size: 10, weight: vm.category == cat.id ? .semibold : .regular))
                                .foregroundColor(vm.category == cat.id ? Colors.primary : Colors.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(vm.category == cat.id ? Color(hex: "#E8F8EE") : Colors.launchBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(vm.category == cat.id ? Colors.primary : Color.clear, lineWidth: 1.5)
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
                    Text(AllStr.Common.location)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Colors.textSecondary)
                    Spacer()
                    if isLocating {
                        ProgressView().scaleEffect(0.7)
                    } else {
                        Button {
                            detectLocation()
                        } label: {
                            Image(systemName: "location.fill.viewfinder")
                                .font(.system(size: 14))
                                .foregroundColor(Colors.primary)
                        }
                    }
                }
                HStack(spacing: 8) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Colors.primary)
                    TextField(AllStr.RecordTransaction.locationPlaceholder, text: $vm.location)
                        .font(.system(size: 14))
                }
                .padding(12)
                .background(Colors.launchBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(AllStr.Common.note)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Colors.textSecondary)
                TextField(AllStr.RecordTransaction.notePlaceholder, text: $vm.note, axis: .vertical)
                    .font(.system(size: 14))
                    .padding(12)
                    .background(Colors.launchBackground)
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
            Text(AllStr.RecordTransaction.photoTitle)
                .font(.system(size: 13))
                .foregroundColor(Colors.textSecondary)

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
                        .foregroundColor(Colors.primary)
                    Text(AllStr.RecordTransaction.photoAttached)
                        .font(.system(size: 13))
                        .foregroundColor(Colors.textPrimary)
                    Spacer()
                    Button { vm.photoPath = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Colors.textHint)
                    }
                }
                .padding(12)
                .background(Colors.launchBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Button {
                    showPhotoAction = true
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Colors.primary)
                        Text(AllStr.RecordTransaction.takePhoto)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Colors.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 80)
                    .background(Colors.launchBackground)
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
            Text(vm.saved ? "✓ \(AllStr.Common.saved)" : AllStr.RecordTransaction.save)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(vm.saved ? Color(hex: "#13A048") : Colors.primary)
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
            let result: NetResponse<nsevfhu> = await Net.shared.uploadImage(
                path: NetPath.kewhbt,
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
