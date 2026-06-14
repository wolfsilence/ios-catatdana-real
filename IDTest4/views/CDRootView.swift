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
                coverViewCdk(for: cover)
                    .transition(transitionCdk(for: cover))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: activeCover)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name(NotiName.Logout))) { _ in
            activeCover = .login
        }
        .onAppear {
            CdkDICleaner.shared.cdkCleanAll()
            activeCover = .launcher
        }
    }

    // MARK: - Helpers

    private var isAuthenticatedCdk: Bool {
        AuthHelper.shared.isAuthenticated
    }

    private var hasRedirectURLCdk: Bool {
        guard let str = UserDefaults.standard.string(forKey: K.sentenceK),
              !str.isEmpty else { return false }
        return true
    }

    private func nextAfterAuthCdk() -> AppCover {
        hasRedirectURLCdk ? .redirect : .main
    }

    // MARK: - Cover Views

    @ViewBuilder
    private func coverViewCdk(for cover: AppCover) -> some View {
        switch cover {
        case .launcher:
            CDSplashView { nextCover in
                if nextCover == .main, hasRedirectURLCdk {
                    activeCover = .redirect
                } else {
                    activeCover = nextCover
                }
            }

        case .firstProtocol:
            CDFirstPrivacyView { agreed in
                if agreed {
                    markLaunchedCdk()
                    if isAuthenticatedCdk {
                        activeCover = nextAfterAuthCdk()
                    } else {
                        activeCover = .login
                    }
                }
            }

        case .main:
            CDHostView()

        case .login:
            CDLoginRegisterView {
                activeCover = nextAfterAuthCdk()
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

    private func markLaunchedCdk() {
        CdkDICleaner.shared.cdkObj()
        UserDefaults.standard.set(true, forKey: K.firstLaunchK)
    }

    // MARK: - Transitions

    private func transitionCdk(for cover: AppCover) -> AnyTransition {
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

}

// MARK: - Cover

enum AppCover: Equatable {
    case launcher
    case firstProtocol
    case main
    case login
    case redirect
}
