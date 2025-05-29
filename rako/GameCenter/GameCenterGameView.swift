//
//  GameCenterGameView.swift
//  gioco
//
//  Created by Francesca Finetti on 22/05/25.
//

import SwiftUI

struct GameCenterGameView: View {
    @ObservedObject var gameCenterManager: GameCenterManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Good! If you're here it means matching works!")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)

            Text("You can leave a feedback saying that the matching works if you want, thanks!")
                .fontWeight(.regular)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button(action: {
                dismiss()
            }) {
                Label("Back to Home", systemImage: "house.fill")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.top, 40)
        }
        .padding()
        .onAppear {
            gameCenterManager.onDataReceived = { data in
                if let string = String(data: data, encoding: .utf8) {
                    print("Received: \(string)")
                }
            }
        }
    }
}

#Preview {
    GameCenterGameView(gameCenterManager: GameCenterManager())
}
