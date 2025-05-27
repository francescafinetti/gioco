
//
//  ContentView.swift
//  gioco
//
//  Created by Francesca Finetti on 08/05/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.dismiss) private var dismiss
    
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
    
    @State private var centralDragOffset: CGSize = .zero
    @State private var isDraggingCentral = false
    @State private var showExitConfirmation = false
    
    var body: some View {
        
        ZStack {
            Image("es")
                .ignoresSafeArea()
            
            VStack {
                
                BotDeckView(viewModel: viewModel, showBotCard: $showBotCard, botOffset: $botOffset)
                
                CentralPileView(
                    viewModel: viewModel,
                    progress: $progress,
                    duration: duration,
                    centralDragOffset: $centralDragOffset,
                    isDraggingCentral: $isDraggingCentral
                )
                
                PlayerDeckView(viewModel: viewModel, dragOffset: $dragOffset, isDragging: $isDragging)
                
                Spacer()
                
            }.padding(.bottom, 250)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showExitConfirmation = true
                } label: {
                    Image(systemName: "house.fill")
                        .foregroundColor(.black)
                }
            }
        }
        
        .onChange(of: viewModel.currentPlayer) { newValue in
            if newValue == 1 {
                showBotCard = true
                botOffset = .zero
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                    withAnimation {
                        botOffset = CGSize(width: 0, height: -200)
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    showBotCard = false
                }
            } else if newValue == 0 {
                startTimer()
            }
        }.alert("Are you sure you want to leave the match?", isPresented: $showExitConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                dismiss()
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
    NavigationStack {
        ContentView()
    }
}
