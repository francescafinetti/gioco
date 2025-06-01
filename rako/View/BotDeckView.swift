//
//  BotDeckView.swift
//  rako
//
//  Created by Serena Pia Capasso on 29/05/25.
//


import SwiftUI

struct BotDeckView: View {
    @ObservedObject var viewModel: GameViewModel
    @Binding var showBotCard: Bool
    @Binding var botOffset: CGSize
    @AppStorage("isLeftHanded") private var isLeftHanded = false

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            HStack {
                ZStack {
                    // Mazzo sotto
                    Image("back_chiaro")
                        .resizable()
                        .frame(width: 200, height: 300)
                        .cornerRadius(10)
                        .shadow(radius: 2)

                    // Carta animata sopra (solo se visibile)
                    if showBotCard {
                        Image("back_chiaro")
                            .resizable()
                            .frame(width: 200, height: 300)
                            .cornerRadius(10)
                            .shadow(radius: 4)
                            .offset(botOffset)
                            .zIndex(1)
                            .animation(.easeInOut(duration: 0.4), value: botOffset)
                    }
                }
                .rotationEffect(.degrees(isLeftHanded ? 210 : -210))
                .position(
                    x: isLeftHanded ? width * 0.70 : width * 0.26,
                    y: height * 0.5
                )
     
                // Punti Giocatore
                

                    VStack(alignment: .center, spacing: 4) {
                        Text("PLAYER 2")
                            .font(.custom("Futura-Bold", size: 22))
                            .bold()
                            .foregroundColor(.black)
                        Text("\(viewModel.players.indices.contains(1) ? viewModel.players[1].count : 0)")
                            .font(.custom("FuturaPT", size: 18))
                            .foregroundColor(.black)
                            .bold()
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                viewModel.currentPlayer == 1 ?
                                    AnyShapeStyle(
                                        LinearGradient(
                                            colors: [Color.blue.opacity(0.3), Color.blue.opacity(0.1)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    :
                                    AnyShapeStyle(Color.gray.opacity(0.04))
                            )
                            .shadow(color: viewModel.currentPlayer == 0 ? Color.blue.opacity(0.4) : .clear, radius: 6, x: 0, y: 0)
                    )
                    .frame(width: 140)
                
                .position(
                    x: isLeftHanded ? screenWidth - 895 : screenWidth - 695,
                    y: screenHeight - 50
                )
            }
        }
        .frame(height: 300)
    }
}

#Preview {
    NavigationStack {
        // Inserire un ViewModel fittizio per preview
        BotDeckView(viewModel: GameViewModel(), showBotCard: .constant(true), botOffset: .constant(.zero))
    }
}

#Preview {
    SinglePlayerView()
}
