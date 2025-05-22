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
        VStack {
            Spacer()
            Text(winner == 0 ? "🎉 Hai vinto!" : "😞 Hai perso")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
                .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}
#Preview {
    EndGameView(winner: 1)
}
