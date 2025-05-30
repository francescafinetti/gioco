//
//  SettingsView.swift
//  gioco
//
//  Created by Francesca Finetti on 21/05/25.
//

import SwiftUI

struct SettingsCardView: View {
    @AppStorage("musicVolume") private var musicVolume: Double = 0.5
    @AppStorage("soundVolume") private var soundVolume: Double = 1.0
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    @AppStorage("isLeftHanded") private var isLeftHanded = false

    var body: some View {
        VStack(spacing: 24) {
            // Music
            HStack {
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 50, height: 50)
                    .overlay(Image(systemName: "music.note").foregroundColor(.white))
                Slider(value: $musicVolume)
                    .accentColor(.accent1)
            }

            // Sound
            HStack {
                Circle()
                    .fill(Color.orange)
                    .frame(width: 50, height: 50)
                    .overlay(Image(systemName: "speaker.wave.2.fill").foregroundColor(.white))
                Slider(value: $soundVolume)
                    .accentColor(.accent1)
            }

            // Vibration
            HStack {
                Circle()
                    .fill(Color.purple)
                    .frame(width: 50, height: 50)
                    .overlay(Image(systemName: "iphone.radiowaves.left.and.right").foregroundColor(.white))
                Spacer()
                Picker("", selection: $vibrationEnabled) {
                    Text("ON").tag(true)
                    Text("OFF").tag(false)
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
            }

            // Hand preference
            HStack {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)
                    .overlay(Image(systemName: "hand.raised.fill").foregroundColor(.white))
                Spacer()
                Picker("", selection: $isLeftHanded) {
                    Text("Left").tag(true)
                    Text("Right").tag(false)
                }
                .pickerStyle(.segmented)
                .frame(width: 140)
            }

            // Tutorial & Credits
            VStack(spacing: 8) {
                Text("Tutorial")
                    .font(.title)
                    .bold()
                Text("Credits")
                    .font(.body)
            }

            Spacer()
        }
        .padding()
        .frame(width: 270)
        .background(
            Image("pic")
                .resizable()
                .scaledToFill()
                .opacity(0.5)
        )
        .cornerRadius(30)
    }
}

#Preview {
    SettingsCardView()
}
