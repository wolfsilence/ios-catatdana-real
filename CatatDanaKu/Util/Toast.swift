import SwiftUI

//
//  Toast.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/4.
//

// MARK: - Toast Modifier

private struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let duration: TimeInterval

    func body(content: Content) -> some View {
        ZStack {
            content

            if isPresented {
                VStack {
                    Spacer()
                    Text(message)
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.bottom, 160)
                }
                .transition(.opacity)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        withAnimation {
                            isPresented = false
                        }
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}

// MARK: - View Extension

extension View {
    /// 显示一个自动消失的 Toast 提示
    /// - Parameters:
    ///   - isPresented: 控制显示/隐藏
    ///   - message: 提示文案
    ///   - duration: 显示时长，默认 2 秒
    func toast(isPresented: Binding<Bool>, message: String, duration: TimeInterval = 2) -> some View {
        modifier(ToastModifier(isPresented: isPresented, message: message, duration: duration))
    }
}
