import SwiftUI

//
//  CDContentView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/4.
//

/// App 根布局 —— 空白底板，业务子页面通过 ZStack + 自定义转场动画弹出
struct CDRootView: View {
    @State private var activeCover: AppCover? = nil

    var body: some View {
        ZStack {
            AppColors.launchBackground
                .ignoresSafeArea()

            if let cover = activeCover {
                coverView(for: cover)
                    .transition(transition(for: cover))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: activeCover)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(NotiName.Logout))) { _ in
            activeCover = .login
        }
        .onAppear {
            activeCover = .launcher
        }
    }

    // MARK: - Cover Views

    @ViewBuilder
    private func coverView(for cover: AppCover) -> some View {
        switch cover {
        case .launcher:
            CDSplashView { nextCover in
                if nextCover == .main, hasRedirectURL {
                    activeCover = .redirect
                } else {
                    activeCover = nextCover
                }
            }

        case .firstProtocol:
            CDFirstPrivacyView { agreed in
                if agreed {
                    markLaunched()
                    if isAuthenticated {
                        activeCover = nextAfterAuth()
                    } else {
                        activeCover = .login
                    }
                }
            }

        case .main:
            CDHostView()

        case .login:
            CDLoginRegisterView {
                activeCover = nextAfterAuth()
            }

        case .redirect:
            CDReadView {
                AuthHelper.shared.clearToken()
                UserDefaults.standard.removeObject(forKey: K.lastLoginPhoneK)
                UserDefaults.standard.removeObject(forKey: K.sentenceK)
                activeCover = .login
            }
        }
    }

    // MARK: - Transitions

    private func transition(for cover: AppCover) -> AnyTransition {
        switch cover {
        case .launcher:
            return .opacity
        case .firstProtocol:
            return .opacity
        case .main:
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        case .login:
            return .asymmetric(
                insertion: .move(edge: .bottom),
                removal: .move(edge: .bottom)
            )
        case .redirect:
            return .opacity
        }
    }

    // MARK: - Helpers

    private var isAuthenticated: Bool {
        AuthHelper.shared.isAuthenticated
    }

    private var hasRedirectURL: Bool {
        guard let str = UserDefaults.standard.string(forKey: K.sentenceK),
              !str.isEmpty else { return false }
        return true
    }

    private func nextAfterAuth() -> AppCover {
        hasRedirectURL ? .redirect : .main
    }

    private func markLaunched() {
        UserDefaults.standard.set(true, forKey: K.firstLaunchK)
    }
}

// MARK: - Cover

enum AppCover: Equatable {
    case launcher
    case firstProtocol
    case main
    case login
    case redirect
}
