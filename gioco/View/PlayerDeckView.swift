//
//  PlayerDeckView.swift
//  gioco
//
//  Created by Serena Pia Capasso on 22/05/25.
//


import SwiftUI

struct PlayerDeckView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var dragOffset: CGSize
    @Binding var isDragging: Bool

    var body: some View {
        VStack(spacing: 8) {
            Text("You – Player 1")
                .font(.subheadline)
                .foregroundColor(.gray)

            ZStack {
                // Mazzo visibile sotto
                Image("back")
                    .resizable()
                    .frame(width: 80, height: 110)
                    .cornerRadius(10)
                    .shadow(radius: 2)

                // Carta da trascinare sopra
                Image("back")
                    .resizable()
                    .frame(width: 80, height: 110)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(viewModel.currentPlayer == 0 ? Color.green.opacity(0.8) : Color.clear, lineWidth: 4)
                            .blur(radius: 1)
                            .opacity(viewModel.currentPlayer == 0 ? 1 : 0)
                    )
                    .offset(dragOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                guard viewModel.currentPlayer == 0 else { return }
                                dragOffset = gesture.translation
                                isDragging = true
                            }
                            .onEnded { gesture in
                                guard viewModel.currentPlayer == 0 else {
                                    dragOffset = .zero
                                    isDragging = false
                                    return
                                }

                                if gesture.translation.height < -120 {
                                    withAnimation {
                                        dragOffset = .zero
                                        isDragging = false
                                        viewModel.playCard()
                                    }
                                } else {
                                    withAnimation {
                                        dragOffset = .zero
                                        isDragging = false
                                    }
                                }
                            }
                    )
            }

            Text("Cards: \(viewModel.players.indices.contains(0) ? viewModel.players[0].count : 0)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
