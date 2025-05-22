//
//  VictoryBannerView.swift
//  gioco
//
//  Created by Serena Pia Capasso on 22/05/25.
//


import SwiftUI

struct VictoryBannerView: View {
    let winner: Int
    let onRestart: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("🎉 Giocatore \(winner + 1) ha vinto!")
                .font(.title2)
                .foregroundColor(.green)
                .bold()

            Button(action: onRestart) {
                Text("🔁 Nuova Partita")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)
            }
        }
    }
}
