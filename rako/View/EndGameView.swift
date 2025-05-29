//
//  EndGameView.swift
//  gioco
//
//  Created by Serena Pia Capasso on 21/05/25.
//

import SwiftUI

struct EndGameView: View {
    let winner: Int

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text(winner == 0 ? "You win" : "You lost")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                
                HStack(spacing: 20) {
                
                    NavigationLink(destination: HomeView()) {
                        Text("Vai alla Home")
                            .fontWeight(.semibold)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                  
                    NavigationLink(destination: SinglePlayerView()) {
                        Text("Play Again")
                            .fontWeight(.semibold)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, 40)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.ignoresSafeArea())
            .navigationTitle("Game Over")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    EndGameView(winner: 1)
}
