
//
//  ContentView.swift
//  gioco
//
//  Created by Francesca Finetti on 08/05/25.
//

import SwiftUI

struct ContentView: View {
    var onExitToHome: (() -> Void)? = nil
    
    @StateObject var viewModel = GameViewModel(playerCount: 2)
    @Namespace private var animation
    @State private var dragOffset: CGSize = .zero
    @State private var botOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var showVictoryBanner = false
    @State private var showBotCard = false
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?
    @State private var showEndGameScreen = false
    let duration: TimeInterval = 7.0

    var body: some View {
        ZStack {
            Image("es")
                .ignoresSafeArea()

            VStack(spacing: 50) {
                Spacer()

                // BOT
                VStack(spacing: 8) {
                    Text("Bot – Player 2")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    ZStack {
                        Image("back")
                            .resizable()
                            .frame(width: 80, height: 110)
                            .cornerRadius(10)
                            .shadow(radius: 2)

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

                // MAZZO CENTRALE
                VStack(spacing: 10) {
                    ZStack {
                        if let lastCard = viewModel.centralPile.last {
                            RoundedRectangle(cornerRadius: 16)
                                .trim(from: 0.0, to: progress / CGFloat(duration))
                                .stroke(Color.black, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 170, height: 263)
                                .animation(.linear(duration: 0.01), value: progress)

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
                                .overlay(Text("Empty").font(.caption).foregroundColor(.gray))
                        }
                    }
                }

                // GIOCATORE
                VStack(spacing: 8) {
                    Text("You – Player 1")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    ZStack {
                        Image("back")
                            .resizable()
                            .frame(width: 80, height: 110)
                            .cornerRadius(10)
                            .shadow(radius: 2)

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

                Spacer()
            }

            if showVictoryBanner, let winner = viewModel.winner {
                VStack {
                    Spacer()
                    Text("🏆 Player \(winner + 1) won the game!")
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

            if newValue == 0 {
                startTimer()
            }
        }
        .onChange(of: viewModel.winner) { winner in
            if winner != nil {
                showVictoryBanner = true
                showEndGameScreen = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showVictoryBanner = false
                }
            }
        }
        .fullScreenCover(isPresented: $showEndGameScreen) {
            if let winner = viewModel.winner {
                EndGameView(
                    winner: winner,
                    onRestart: {
                        viewModel.startGame(playerCount: 2)
                        showEndGameScreen = false
                    },
                    onGoHome: {
                        showEndGameScreen = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onExitToHome?()
                        }
                    }
                )
            }
        }
    }

    func startTimer() {
        progress = CGFloat(duration)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { t in
            if progress > 0 {
                progress -= 0.01
            } else {
                progress = 0
                t.invalidate()
            }
        }
    }
}

#Preview {
    ContentView()
}
