//
//  RulesLoopView.swift
//  rako
//
//  Created by Francesca Finetti on 06/06/25.
//
import SwiftUI

struct RulesLoopPage: View {
    let title: String
    let description: String
    let imageNames: [String]
    
    @State private var currentImageIndex = 0
    let timer = Timer.publish(every: 0.8, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.custom("Futura-Bold", size: 30))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 60)
            
            Text(description)
                .font(.custom("FuturaPT", size: 18))
                .foregroundColor(.black.opacity(0.95))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            
            Image(imageNames[currentImageIndex])
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 1000)
                .cornerRadius(25)
                .shadow(radius: 10)
                .padding(.horizontal, 20)
                .onReceive(timer) { _ in
                    currentImageIndex = (currentImageIndex + 1) % imageNames.count
                }
            
            Spacer(minLength: 0)
        }
    }
}
