//
//  Untitled.swift
//  gioco
//
//  Created by Francesca Finetti on 22/05/25.
//

import SwiftUI

struct GameCenterConnectView: View {
    @StateObject private var gameCenterManager = GameCenterManager()

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("Game Center Multiplayer")
                    .font(.largeTitle)
                    .bold()

                Button("Matchmaking Online") {
                    gameCenterManager.presentMatchmaker()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                NavigationLink(
                    destination: GameCenterGameView(gameCenterManager: gameCenterManager),
                    isActive: $gameCenterManager.isConnected,
                    label: { EmptyView() }
                )

                if gameCenterManager.isConnected {
                    Text("Connected, Loading the Game...")
                        .foregroundColor(.green)
                } else {
                    Text("Waiting for Connection...")
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
    }
}
