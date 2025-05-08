//
//  ContentView.swift
//  gioco
//
//  Created by Francesca Finetti on 08/05/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = GameViewModel(playerCount: 2)
    @Namespace private var animation
    @State private var dragOffset: CGSize = .zero
    @State private var botOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var showVictoryBanner = false
    @State private var showBotCard = false

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color(UIColor.systemGray6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 50) {
                
                Spacer()

                // BOT DECK
                VStack(spacing: 8) {
                    Text("Bot – Giocatore 2")
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
                                .frame(width: 80, height: 110)                                .cornerRadius(10)
                                .shadow(radius: 4)
                                .offset(botOffset)
                                .zIndex(1)
                                .animation(.easeInOut(duration: 0.4), value: botOffset)
                        }
                    }

                    Text("Carte: \(viewModel.players.indices.contains(1) ? viewModel.players[1].count : 0)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // MAZZO CENTRALE
                VStack(spacing: 10) {
                    ZStack {
                        if let lastCard = viewModel.centralPile.last {
                            Image(lastCard.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 250)
                                .cornerRadius(14)
                                .shadow(radius: 6)
                                .transition(.scale)
                                .onTapGesture {
                                    if viewModel.centralPile.count >= 2 {
                                        let top = viewModel.centralPile.last!
                                        let second = viewModel.centralPile[viewModel.centralPile.count - 2]
                                        if top.value == second.value {
                                            viewModel.tapForDoppia(by: 0)
                                        }
                                    }
                                }
                        } else {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 200, height: 250)
                                .overlay(Text("Vuoto").font(.caption).foregroundColor(.gray))
                        }
                    }
                }


                // PLAYER DECK
                VStack(spacing: 8) {
                    Text("Tu – Giocatore 1")
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
                            .offset(dragOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        guard viewModel.currentPlayer == 0 else { return } // 👈 blocco se non è il tuo turno
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

                    Text("Carte: \(viewModel.players.indices.contains(0) ? viewModel.players[0].count : 0)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                

                // FINE PARTITA
                if let winner = viewModel.winner {
                    VStack(spacing: 12) {
                        Text("🎉 Giocatore \(winner + 1) ha vinto!")
                            .font(.title2)
                            .foregroundColor(.green)
                            .bold()

                        Button(action: {
                            viewModel.startGame(playerCount: 2)
                        }) {
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
                    .onAppear {
                        if !showVictoryBanner {
                            showVictoryBanner = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                showVictoryBanner = false
                            }
                        }
                    }
                }

                Spacer()
            }

            // BANNER DI VITTORIA
            if showVictoryBanner, let winner = viewModel.winner {
                VStack {
                    Spacer()
                    Text("🏆 Giocatore \(winner + 1) ha vinto la partita!")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .background(.black.opacity(0.85))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                        .transition(.opacity)
                    Spacer()
                }
                .zIndex(2)
            }
        }
        .onChange(of: viewModel.currentPlayer) { newValue in
            if newValue == 1 {
                showBotCard = true
                botOffset = .zero

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation {
                        botOffset = CGSize(width: 0, height: 200)
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showBotCard = false
                }
            }
        }
        .onChange(of: viewModel.winner) { winner in
            if winner != nil {
                showVictoryBanner = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showVictoryBanner = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

