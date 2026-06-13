import SwiftUI

//
//  View+Loading.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/4.
//

// MARK: - Loading Modifier

private struct LoadingModifier: ViewModifier {
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        ZStack {
            content
                .allowsHitTesting(!isPresented)

            if isPresented {
                Color.black.opacity(0.16)
                    .ignoresSafeArea()
                    .transition(.opacity)

                ProgressView()
                    .scaleEffect(1.3)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}

// MARK: - View Extension

extension View {
    /// 显示全屏 loading 遮罩（菊花转圈）
    func loading(isPresented: Binding<Bool>) -> some View {
        modifier(LoadingModifier(isPresented: isPresented))
    }
}
