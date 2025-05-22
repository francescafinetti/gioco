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
                Text("Scegli modalità")
                    .font(.title)
                    .bold()

                NavigationLink(destination: ConnectView()) {
                    Text("Gioco Locale (Bluetooth/Wi-Fi)")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

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


