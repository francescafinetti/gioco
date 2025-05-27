//
//  giocoApp.swift
//  gioco
//
//  Created by Francesca Finetti on 08/05/25.
//

import SwiftUI
import GameKit

@main
struct giocoApp: App {
    init() {
        authenticateGameCenterUser()
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
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
