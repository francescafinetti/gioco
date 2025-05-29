//
//  TwoPlayerGameView.swift
//  gioco
//
//  Created by Giovanni Fioretto on 23/05/25.
//



import SwiftUI
import UniformTypeIdentifiers

struct TwoPlayerGameView: View {
    @StateObject var viewModel = GameViewModel(playerCount: 2, isCPUEnabled: false)
    @Namespace private var animation
    @Environment(\.dismiss) private var dismiss
    
    // Drag states for central card
    @State private var centralDragOffset: CGSize = .zero
    @State private var isDraggingCentral = false
    
    // Drag states for player decks
    @State private var player1DragOffset: CGSize = .zero
    @State private var isPlayer1Dragging = false
    @State private var player2DragOffset: CGSize = .zero
    @State private var isPlayer2Dragging = false
    
    // Victory banner
    @State private var showVictoryBanner = false
    
    // Timer for central pile
    @State private var progress: CGFloat = 0.0
    @State private var timer: Timer?
    let duration: TimeInterval = 7.0
    
    var body: some View {
        ZStack {
            Image( "pic" )
                .ignoresSafeArea()
            
            VStack {
                // PLAYER 2 DECK (top)
                VStack {
                    HStack {
                        GeometryReader { geometry in
                            let width = geometry.size.width
                            let height = geometry.size.height
                            let screenWidth = geometry.size.width
                            let screenHeight = geometry.size.height
                            
                            Image("back_chiaro")
                                .resizable()
                                .frame(width: 200, height: 300)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .offset(player2DragOffset)
                                .gesture(
                                    DragGesture()
                                        .onChanged { g in
                                            guard viewModel.currentPlayer == 1 else { return }
                                            player2DragOffset = g.translation
                                            isPlayer2Dragging = true
                                        }
                                        .onEnded { g in
                                            guard viewModel.currentPlayer == 1 else {
                                                withAnimation { resetPlayer2Drag() }
                                                return
                                            }
                                            if g.translation.height > 120 {
                                                viewModel.playCard()
                                            }
                                            withAnimation { resetPlayer2Drag() }
                                        }
                                )
                                .rotationEffect(.degrees(-25))
                                .position(x: width * 0.30, y: height * 0.30)
                            
                            
                            VStack {
                                Text("Player 2")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.black)
                                Text("\(viewModel.players.indices.contains(1) ? viewModel.players[1].count : 0)")
                                    .font(.title3)
                                    .foregroundColor(.black)
                                    .bold()
                            }  .padding(12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.04)))
                                .frame(width: 140)
                                .position(x: screenWidth - 290, y: screenHeight - 45)
                            
                        }
                    }
                    .padding(.top, 50)
                    
                    // CENTRAL PILE
                    ZStack {
                        if let lastCard = viewModel.centralPile.last {
                            
                            // TIMER AROUND THE CARD
                            RoundedRectangle(cornerRadius: 16)
                                .trim(from: 0.0, to: progress / CGFloat(duration))
                                .stroke(Color.black, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 170, height: 263)
                                .animation(.linear(duration: 0.01), value: progress)
                            
                            // CENTRAL CARD DRAGGABLE
                            Image(lastCard.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 280, height: 400)
                                .cornerRadius(14)
                                .shadow(radius: 6)
                                .offset(centralDragOffset)
                                .gesture(
                                    DragGesture()
                                        .onChanged { g in
                                            centralDragOffset = CGSize(width: 0, height: g.translation.height)
                                            isDraggingCentral = true
                                        }
                                        .onEnded { g in
                                            defer {
                                                withAnimation(.easeOut) {
                                                    centralDragOffset = .zero
                                                    isDraggingCentral = false
                                                }
                                            }
                                            
                                            guard viewModel.centralPile.count >= 2 else { return }
                                            let topVal = viewModel.centralPile.last!.value
                                            let secVal = viewModel.centralPile[viewModel.centralPile.count - 2].value
                                            guard topVal == secVal else { return }
                                            
                                            let threshold: CGFloat = 100
                                            if g.translation.height > threshold {
                                                print("Giocatore 1 ha trascinato coppia")
                                                viewModel.tapForDoppia(by: 0)
                                            } else if g.translation.height < -threshold {
                                                print("Giocatore 2 ha trascinato coppia")
                                                viewModel.tapForDoppia(by: 1)
                                            }
                                        }
                                )
                                .transition(.scale)
                            
                        } else {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 260, height: 410)
                                .overlay(Text("Empty").font(.caption).foregroundColor(.gray))
                        }
                    }
                    
                    
                    
                    // PLAYER 1 DECK (bottom)
                    HStack {
                        GeometryReader { geometry in
                            let width = geometry.size.width
                            let height = geometry.size.height
                            let screenWidth = geometry.size.width
                            let screenHeight = geometry.size.height
                            
                            VStack {
                                
                                Text("Player 1")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.black)
                                Text("\(viewModel.players.indices.contains(0) ? viewModel.players[0].count : 0)")
                                    .font(.title3)
                                    .foregroundColor(.black)
                                    .bold()
                            }  .padding(12)
                                .background(RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.04)))
                                .frame(width: 140)
                                .position(x: screenWidth - 480, y: screenHeight - 250)
                            
                            
                            
                            Image("back_chiaro")
                                .resizable()
                                .frame(width: 200, height: 300)
                                .cornerRadius(10)
                                .shadow(radius: 2)
                                .offset(player1DragOffset)
                                .gesture(
                                    DragGesture()
                                        .onChanged { g in
                                            guard viewModel.currentPlayer == 0 else { return }
                                            player1DragOffset = g.translation
                                            isPlayer1Dragging = true
                                        }
                                        .onEnded { g in
                                            guard viewModel.currentPlayer == 0 else {
                                                withAnimation { resetPlayer1Drag() }
                                                return
                                            }
                                            if g.translation.height > 120 {
                                                viewModel.playCard()
                                            }
                                            withAnimation { resetPlayer1Drag() }
                                        }
                                    
                                )
                                .rotationEffect(.degrees(-210))
                                .position(x: width * 0.70, y: height * 0.60)
                            
                        }
                    }
                    .onChange(of: viewModel.currentPlayer) { _ in
                        startTimer()
                        
                        
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    func startTimer() {
        progress = CGFloat(duration)
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { t in
            if progress > 0 { progress -= 0.01 } else { progress = 0; t.invalidate() }
        }
    }
    
    private func resetPlayer1Drag() {
        player1DragOffset = .zero
        isPlayer1Dragging = false
    }
    private func resetPlayer2Drag() {
        player2DragOffset = .zero
        isPlayer2Dragging = false
    }
}

#Preview {
    TwoPlayerGameView()
}
