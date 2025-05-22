//
//  BotDeckView.swift
//  gioco
//
//  Created by Serena Pia Capasso on 22/05/25.
//


import SwiftUI

struct BotDeckView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var showBotCard: Bool
    @Binding var botOffset: CGSize

    var body: some View {
        VStack(spacing: 8) {
            Text("Bot – Player 2")
                .font(.subheadline)
                .foregroundColor(.gray)

            ZStack {
                // Mazzo sotto
                Image("back")
                    .resizable()
                    .frame(width: 80, height: 110)
                    .cornerRadius(10)
                    .shadow(radius: 2)

                // Carta animata sopra (solo se visibile)
                if showBotCard {
                    Image("back")
                        .resizable()
                        .frame(width: 80, height: 110)
                        .cornerRadius(10)
                        .shadow(radius: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(viewModel.currentPlayer == 1 ? Color.green.opacity(0.8) : Color.clear, lineWidth: 4)
                                .blur(radius: 1)
                                .opacity(viewModel.currentPlayer == 1 ? 1 : 0)
                        )
                        .offset(botOffset)
                        .zIndex(1)
                        .animation(.easeInOut(duration: 0.4), value: botOffset)
                }
            }

            Text("Cards: \(viewModel.players.indices.contains(1) ? viewModel.players[1].count : 0)")
                .font(.caption)
                .foregroundColor(.secondary)
        }

    }
}
