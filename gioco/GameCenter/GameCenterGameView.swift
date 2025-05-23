//
//  Untitled.swift
//  gioco
//
//  Created by Francesca Finetti on 22/05/25.
//

import SwiftUI

struct GameCenterGameView: View {
    @ObservedObject var gameCenterManager: GameCenterManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Online Game View")
                .font(.largeTitle)
                .bold()

            Button("Send message") {
                let testMessage = "hi"
                if let data = testMessage.data(using: .utf8) {
                    gameCenterManager.send(data)
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Text("messages are controlled here")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .onAppear {
            gameCenterManager.onDataReceived = { data in
                if let string = String(data: data, encoding: .utf8) {
                    print("Messaggio ricevuto: \(string)")
                }
            }
        }
    }
}

