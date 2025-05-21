//
//  EndGameView.swift
//  gioco
//
//  Created by Serena Pia Capasso on 21/05/25.
//

import SwiftUI

struct EndGameView: View {
    let winner: Int
    let onRestart: () -> Void
    let onGoHome: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            if winner == 0 {
                Text("🎉 Hai vinto!")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.green)
            } else {
                Text("💀 Hai perso!")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.red)
            }

            Spacer()

            VStack(spacing: 20) {
                ForEach([
                    ("🔁 Gioca una nuova partita", onRestart, Color.blue),
                    ("🏠 Torna alla Home", onGoHome, Color.gray)
                ], id: \.0) { (title, action, color) in
                    Button(action: action) {
                        Text(title)
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(color)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .ignoresSafeArea()
    }
}

#Preview("Hai Vinto") {
    EndGameView(winner: 0,
                onRestart: { print("Restart tapped") },
                onGoHome: { print("Home tapped") })
}
