
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

                // MAZZO CENTRALE
                VStack(spacing: 10) {
                    ZStack {
                        if let lastCard = viewModel.centralPile.last {

                            // TIMER AROUND THE CARD
                            RoundedRectangle(cornerRadius: 16)
                                .trim(from: 0.0, to: progress / CGFloat(duration))
                                .stroke(Color.black, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 170, height: 263)
                                .animation(.linear(duration: 0.01), value: progress)

                            // CARD DISPLAYED
                            Image(lastCard.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 250)
                                .cornerRadius(14)
                                .shadow(radius: 6)
                                .transition(.scale)
                                .gesture(
                                    DragGesture()
                                        .onChanged { gesture in
                                            //valuta solo coordinate Y nel drag
                                            centralDragOffset = CGSize(width: 0, height: gesture.translation.height)
                                            isDraggingCentral = true
                                        }
                                        .onEnded { gesture in
                                            //rimettere carta in posizione dritta alla fine
                                            defer {
                                                withAnimation(.easeOut) {
                                                    centralDragOffset = .zero
                                                    isDraggingCentral = false
                                                }
                                            }
                                            
                                            //ci soo almeno 2 carte?
                                            guard viewModel.centralPile.count >= 2 else { return }
                                            let topValue    = viewModel.centralPile.last!.value
                                            let secondValue = viewModel.centralPile[viewModel.centralPile.count - 2].value
                                            guard topValue == secondValue else { return }
                                            
                                            //soglia è per dare un minimo di trascinamento
                                            let soglia: CGFloat = 100
                                            if gesture.translation.height > soglia {
                                                //drag verso il basso carte verso player 1
                                                print("Giocatore 1 ha trascinato coppia")
                                                viewModel.tapForDoppia(by: 0)
                                            } else if gesture.translation.height < -soglia {
                                                //drag verso l’alto carte player 2 (o bot)
                                                print("Giocatore 2 ha trascinato coppia")
                                                viewModel.tapForDoppia(by: 1)
                                            }
                                        }
                                )
                                .transition(.scale)
                                /*
                                 vecchio vers "tap" per la coppia
                                 .onTapGesture {
                                    if viewModel.centralPile.count >= 2 {
                                        let top = viewModel.centralPile.last!
                                        let second = viewModel.centralPile[viewModel.centralPile.count - 2]
                                        if top.value == second.value {
                                            viewModel.tapForDoppia(by: 0)
                                        }
                                    }
                                }*/
                        } else {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 200, height: 250)
                                .overlay(Text("Empty").font(.caption).foregroundColor(.gray))
                        }
                    }
                }

                // PLAYER DECK
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
