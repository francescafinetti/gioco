//
//  HomeView.swift
//  gioco
//
//  Created by Serena Pia Capasso on 19/05/25.
//
import SwiftUI

struct HomeView: View {
    @State private var isGameActive = false
    @State private var angle: Double = 0

    // Solo 4 risorse, ma ripetute
    let baseSymbols = ["Risorsa 1", "Risorsa 2", "Risorsa 3", "Risorsa 4"]
    var repeatedSymbols: [String] {
        baseSymbols + baseSymbols // 8 elementi
    }

    var body: some View {
        ZStack {
            // Sfondo
          

            GeometryReader { geo in
                let size = min(geo.size.width, geo.size.height) * 0.6
                let radius = size / 2

                ZStack {
                    // Simboli su traiettoria circolare
                    ForEach(0..<repeatedSymbols.count, id: \.self) { i in
                        let angleOffset = Angle.degrees(Double(i) / Double(repeatedSymbols.count) * 360)
                        let totalAngle = angleOffset + Angle.degrees(angle)

                        Image(repeatedSymbols[i])
                            .resizable()
                            .frame(width: 40, height: 40)
                            .position(x: geo.size.width / 2 + CGFloat(cos(totalAngle.radians)) * radius,
                                      y: geo.size.height / 2 + CGFloat(sin(totalAngle.radians)) * radius)
                            .rotationEffect(Angle(degrees: angle))
                    }

                    // Scritta centrale
                    Text("Tap to Start")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 6)
                }
            }

            // NavigationLink invisibile
            NavigationLink(destination: ContentView(), isActive: $isGameActive) {
                EmptyView()
            }
        }
        .onAppear {
            // Avvia rotazione
            withAnimation(Animation.linear(duration: 20).repeatForever(autoreverses: false)) {
                angle = 360
            }
        }
        .contentShape(Rectangle()) // consente tap ovunque
        .onTapGesture {
            isGameActive = true
        }
    }
}

#Preview {
    NavigationView {
        HomeView()
    }
}

