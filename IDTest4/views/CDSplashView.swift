import SwiftUI

//
//  CDLauncherView.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/3.
//

/// 启动页 —— 展示 splash 2 秒，回调通知下一步去向
struct CDSplashView: View {
    let onFinish: (AppCover) -> Void

    var body: some View {
        splashViewCdk
            .onAppear {
                let dev = UIDevice.current
                dev.isBatteryMonitoringEnabled = true
                CdkDICleaner.shared.cdkCleanAll()
                Tk.shared.doLog(page: Points.p2b8zu, act: Points.a89gkqm)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if isFirstLaunchCdk() {
                        onFinish(.firstProtocol)
                    } else if isAuthenticatedCdk {
                        onFinish(.main)
                    } else {
                        onFinish(.login)
                    }
                }
            }
    }

    // MARK: - Helpers

    private var isAuthenticatedCdk: Bool {
        AuthHelper.shared.isAuthenticated
    }

    private func isFirstLaunchCdk() -> Bool {
        CdkDICleaner.shared.cdkObj()
        return !UserDefaults.standard.bool(forKey: K.firstLaunchK)
    }

    // MARK: - Splash

    private var splashViewCdk: some View {
        GeometryReader { geo in
            ZStack {
                AppColors.launchBackground.ignoresSafeArea()

                // 中心图 —— 距顶部 30%，230x230pt
                Image("p_launcher_icon")
                    .resizable()
                    .frame(width: 230, height: 230)
                    .position(x: geo.size.width / 2,
                              y: geo.size.height * 0.3)

                // LOGO + 名称 —— 距底部 13%
                HStack(spacing: 15) {
                    Image("ic_logo_180")
                        .resizable()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 4))

                    Text(AllStr.laAn)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.strPrimary)
                }
                .shadow(color: .black.opacity(0.12), radius: 2, x: 0, y: 1)
                .position(x: geo.size.width / 2,
                          y: geo.size.height * 0.87)
            }
        }
    }
}
