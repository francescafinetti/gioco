//
//  Untitled.swift
//  gioco
//
//  Created by Francesca Finetti on 22/05/25.
//

import SwiftUI

struct HomeGameCenterView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Text("Select Game Mode")
                    .font(.title)
                    .bold()

                NavigationLink(destination: GameCenterConnectView()) {
                    Text("Game Center Online")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
    }
}

#Preview {
    HomeGameCenterView()
}


