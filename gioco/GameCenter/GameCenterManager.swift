//
//  Untitled.swift
//  gioco
//
//  Created by Francesca Finetti on 22/05/25.
//

import Foundation
import GameKit
import SwiftUI

class GameCenterManager: NSObject, ObservableObject, GKMatchmakerViewControllerDelegate, GKMatchDelegate {
    @Published var match: GKMatch?
    @Published var isConnected = false
    var onDataReceived: ((Data) -> Void)?

    func presentMatchmaker() {
        let request = GKMatchRequest()
        request.minPlayers = 2
        request.maxPlayers = 2

        guard let viewController = GKMatchmakerViewController(matchRequest: request) else { return }
        viewController.matchmakerDelegate = self

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(viewController, animated: true)
        }
    }

    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFind match: GKMatch) {
        print("✅ Match found!")
        self.match = match
        match.delegate = self
        isConnected = true
        viewController.dismiss(animated: true)
    }

    func matchmakerViewControllerWasCancelled(_ viewController: GKMatchmakerViewController) {
        print("❌ Matchmaking annullato")
        viewController.dismiss(animated: true)
    }

    func matchmakerViewController(_ viewController: GKMatchmakerViewController, didFailWithError error: Error) {
        print("❌ Errore matchmaking: \(error.localizedDescription)")
        viewController.dismiss(animated: true)
    }

    func match(_ match: GKMatch, didReceive data: Data, fromRemotePlayer player: GKPlayer) {
        print("📨 Dati ricevuti da \(player.displayName)")
        onDataReceived?(data)
    }

    func send(_ data: Data) {
        guard let match = match else { return }
        do {
            try match.sendData(toAllPlayers: data, with: .reliable)
            print("📤 Dati inviati a tutti")
        } catch {
            print("❌ Errore invio dati: \(error.localizedDescription)")
        }
    }
}



