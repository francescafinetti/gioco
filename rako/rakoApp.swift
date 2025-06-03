//
//  giocoApp.swift
//  gioco
//
//  Created by Francesca Finetti on 08/05/25.
//

import SwiftUI
import GameKit

@main
struct rakoApp: App {
    // Collegamento AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        authenticateGameCenterUser()
    }

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                if hasSeenOnboarding {
                    HomeView()
                } else {
                    OnboardingView()
                }
            }
            .environment(\.colorScheme, .light) // 🔒 Modalità chiara forzata
        }
    }

    func authenticateGameCenterUser() {
        let player = GKLocalPlayer.local
        player.authenticateHandler = { vc, error in
            if let viewController = vc {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first?.rootViewController {
                    rootVC.present(viewController, animated: true)
                }
            } else if player.isAuthenticated {
                print("🎮 Game Center autenticato come: \(player.alias)")
            } else {
                print("❌ Game Center non autenticato")
            }

            if let error = error {
                print("Errore Game Center: \(error.localizedDescription)")
            }
        }
    }
}

// 🔒 AppDelegate per bloccare la rotazione
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait // Solo verticale
    }
}
