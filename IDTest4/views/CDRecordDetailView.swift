import SwiftUI

//
//  CDTransactionDetailView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/9.
//

struct CDRecordDetailView: View {
    @State private var transaction: EntityTrade
    @State private var showFullImage = false
    @State private var cachedImage: UIImage?

    let onBack: () -> Void

    init(transaction: EntityTrade, onBack: @escaping () -> Void) {
        _transaction = State(initialValue: transaction)
        self.onBack = onBack
    }

    private var categoryCdk: TransactionCategory? {
        TransactionCategory.all.first { $0.id == transaction.category }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                pageHeaderCdk

                ScrollView {
                    VStack(spacing: 20) {
                        amountSectionCdk
                        infoCardsCdk
                        if !transaction.photo.isEmpty {
                            photoSectionCdk
                        }
                    }
                    .padding(20)
                }
            }
            .background(AppColors.launchBackground)

            // 全屏图片查看
            if showFullImage {
                fullScreenImageViewerCdk
            }
        }
        .task {
            CdkDICleaner.shared.cdkClean()
            await submitBizAndReloadCdk()
            await loadCachedImageCdk()
        }
    }

    // MARK: - Image Cache

    private func loadCachedImageCdk() async {
        guard !transaction.photo.isEmpty,
              let url = URL(string: transaction.photo) else { return }
        if let data = try? await URLSession.shared.data(from: url).0,
           let image = UIImage(data: data) {
            await MainActor.run { cachedImage = image }
        }
    }

    // MARK: - Photo

    private var photoSectionCdk: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(AllStr.tdPh)
                .font(.system(size: 13))
                .foregroundColor(AppColors.strSecondary)

            Button {
                showFullImage = true
            } label: {
                if let image = cachedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .frame(height: 120)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

    private func fullDateCdk(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "id_ID")
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // MARK: - API

    private func submitBizAndReloadCdk() async {
        let req = Entity20(pclb: "transaction", qkipkeyov: [
            "action": "view",
            "transaction_id": transaction.id,
        ])
        let _: NetResp<EmptyResp> = await Net.shared.post(
            path: Paths.halkm,
            encodableBody: req
        )
        // 从本地重新捞取最新数据
        let all = DatabaseHelper.shared.loadTransactions()
        if let updated = all.first(where: { $0.id == transaction.id }) {
            transaction = updated
        }
    }

    // MARK: - Info Cards

    private var infoCardsCdk: some View {
        VStack(spacing: 12) {
            // Category
            infoRowCdk(
                icon: "square.grid.2x2.fill",
                title: AllStr.tdC,
                value: categoryCdk?.label ?? transaction.category,
                valueIcon: categoryCdk?.icon
            )

            Divider().padding(.leading, 44)

            // Date
            infoRowCdk(
                icon: "calendar",
                title: AllStr.tdDa,
                value: fullDateCdk(transaction.date)
            )

            // Location
            if !transaction.loc.isEmpty {
                Divider().padding(.leading, 44)
                infoRowCdk(
                    icon: "location.fill",
                    title: AllStr.tdL,
                    value: transaction.loc
                )
            }

            // Note
            if !transaction.tip.isEmpty {
                Divider().padding(.leading, 44)
                infoRowCdk(
                    icon: "doc.text.fill",
                    title: AllStr.tdN,
                    value: transaction.tip
                )
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

    // MARK: - Header

    private var pageHeaderCdk: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                ZStack {
                    Circle().fill(AppColors.launchBackground).frame(width: 36, height: 36)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppColors.strPrimary)
                }
            }
            Text(AllStr.tdT)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(AppColors.strPrimary)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.white)
    }

    // MARK: - Fullscreen Image Viewer

    private var fullScreenImageViewerCdk: some View {
        ZoomableImageView(
            image: cachedImage,
            onDismiss: { showFullImage = false }
        )
        .ignoresSafeArea()
        .zIndex(100)
    }

    // MARK: - Amount

    private var amountSectionCdk: some View {
        VStack(spacing: 12) {
            // Type badge
            Text(transaction.type == .income ? AllStr.cmI : AllStr.cmE)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(transaction.type == .income ? AppColors.primary : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(transaction.type == .income ? Color(hex: "#E8F8EE") : .red)
                .clipShape(Capsule())

            // Amount
            Text(transaction.type == .income
                 ? "+\(formatIDR(transaction.num))"
                 : "-\(formatIDR(transaction.num))")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(transaction.type == .income ? AppColors.primary : .red)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 2, y: 1)
    }

    // MARK: - Row

    private func infoRowCdk(icon: String, title: String, value: String, valueIcon: String? = nil) -> some View {
        CdkDICleaner.shared.cdkDeviceCheck()
        return HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppColors.primary)
                .frame(width: 24)

            Text(title)
                .font(.system(size: 14))
                .foregroundColor(AppColors.strSecondary)

            Spacer()

            if let valueIcon {
                Text(valueIcon).font(.system(size: 16))
            }
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(AppColors.strPrimary)
        }
    }
}

// MARK: - Zoomable Image View (UIScrollView native zoom)

private struct ZoomableImageView: View {
    let image: UIImage?
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            NativeZoomScrollView(image: image, onDismiss: onDismiss)

            // 关闭按钮
            VStack {
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 50)
                Spacer()
            }
        }
    }
}

private struct NativeZoomScrollView: UIViewRepresentable {
    let image: UIImage?
    let onDismiss: () -> Void

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.backgroundColor = .black

        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tag = 100
        scrollView.addSubview(imageView)

        // 双击缩放
        let doubleTap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDoubleTapCdk(_:))
        )
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)

        // 单击关闭
        let singleTap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleSingleTapCdk(_:))
        )
        singleTap.numberOfTapsRequired = 1
        singleTap.require(toFail: doubleTap)
        scrollView.addGestureRecognizer(singleTap)

        // 延迟到布局完成后设置图片
        if let img = image {
            imageView.image = img
            imageView.frame = CGRect(origin: .zero, size: img.size)
            scrollView.contentSize = img.size
            DispatchQueue.main.async {
                let widthRatio = scrollView.bounds.width / img.size.width
                let heightRatio = scrollView.bounds.height / img.size.height
                let minRatio = min(widthRatio, heightRatio)
                guard minRatio > 0, minRatio.isFinite else { return }
                scrollView.minimumZoomScale = minRatio
                scrollView.zoomScale = minRatio
                let offsetX = max((scrollView.bounds.width - img.size.width * minRatio) * 0.5, 0)
                let offsetY = max((scrollView.bounds.height - img.size.height * minRatio) * 0.5, 0)
                scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
            }
        }

        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        let onDismiss: () -> Void

        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            scrollView.viewWithTag(100)
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            guard let imageView = scrollView.viewWithTag(100) else { return }
            let offsetX = max((scrollView.bounds.width - imageView.frame.width) * 0.5, 0)
            let offsetY = max((scrollView.bounds.height - imageView.frame.height) * 0.5, 0)
            scrollView.contentInset = UIEdgeInsets(top: offsetY, left: offsetX, bottom: offsetY, right: offsetX)
        }

        @objc func handleDoubleTapCdk(_ gesture: UITapGestureRecognizer) {
            CdkDICleaner.shared.cdkObj()
            guard let scrollView = gesture.view as? UIScrollView else { return }
            if scrollView.zoomScale > 1.0 {
                scrollView.setZoomScale(1.0, animated: true)
            } else {
                let point = gesture.location(in: scrollView.viewWithTag(100))
                let rect = CGRect(x: point.x - 1, y: point.y - 1, width: 2, height: 2)
                scrollView.zoom(to: rect, animated: true)
            }
        }

        @objc func handleSingleTapCdk(_ gesture: UITapGestureRecognizer) {
            onDismiss()
        }
    }
}
