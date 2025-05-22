
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
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?
    let duration: TimeInterval = 7.0
    
    //var per drag coppiauz
    @State private var centralDragOffset: CGSize = .zero//tracciare movimento
    /* da usare in caso di cambio visuale*/
     @State private var isDraggingCentral = false
   
    

    var body: some View {
        ZStack {
            // Background
            Image("es")
                .ignoresSafeArea()

            VStack(spacing: 50) {

                Spacer()

                // BOT DECK
                BotDeckView(viewModel: viewModel, showBotCard: $showBotCard, botOffset: $botOffset)
                // MAZZO CENTRALE
                CentralPileView(viewModel: viewModel, progress: $progress, duration: duration, centralDragOffset: $centralDragOffset, isDraggingCentral: $isDraggingCentral)

                // PLAYER DECK
                
                PlayerDeckView(viewModel: viewModel, dragOffset: $dragOffset, isDragging: $isDragging)

                // FINE PARTITA
                if let winner = viewModel.winner {
                    VictoryBannerView(winner: winner) {
                                           viewModel.startGame(playerCount: 2)
                                       }
                }

                Spacer()
            }

            // BANNER DI VITTORIA
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
        }
        .onChange(of: viewModel.winner) { winner in
            if winner != nil {
                showVictoryBanner = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    showVictoryBanner = false
                }
            }
        }
        .onChange(of: viewModel.currentPlayer) { newValue in
            if newValue == 0 {
                startTimer()
            }
        }
    }

    func startTimer() {
        progress = CGFloat(duration) // parte sempre pieno
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
