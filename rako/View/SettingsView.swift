//
//  SettingsCardView.swift
//  rako
//
//  Created by Francesca Fientti on 29/05/25.
//

import SwiftUI

struct SettingsCardView: View {
    @AppStorage("musicVolume") private var musicVolume: Double = 0.5
    @AppStorage("soundVolume") private var soundVolume: Double = 1.0
    @AppStorage("volumeEnabled") private var volumeEnabled: Bool = true
    @AppStorage("soundEnabled") private var soundEnabled: Bool = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    @AppStorage("isLeftHanded") private var isLeftHanded = false

    var body: some View {
        VStack(spacing: 35) {

            // Musica (on/off + slider)
            HStack {
                Button {
                    volumeEnabled.toggle()
                    if volumeEnabled {
                        AudioManager.shared.startBackgroundMusic()
                        AudioManager.shared.setCurrentVolume(to: Float(musicVolume))
                    } else {
                        AudioManager.shared.stopMusic()
                    }
                } label: {
                    Circle()
                        .fill(volumeEnabled ? Color.green : Color.gray)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: volumeEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                                .foregroundColor(.white)
                        )
                }

                Slider(value: $musicVolume, in: 0...1)
                    .accentColor(.accent1)
                    .disabled(!volumeEnabled)
                    .onChange(of: musicVolume) { newVolume in
                        if volumeEnabled {
                            AudioManager.shared.setCurrentVolume(to: Float(newVolume))
                        }
                    }
            }
            // Vibrazione
            /*
            // Suoni (on/off + slider)
            HStack {
                Button {
                    soundEnabled.toggle()
                    // In futuro: attiva/disattiva effetti sonori
                } label: {
                    Circle()
                        .fill(soundEnabled ? Color.orange : Color.gray)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: soundEnabled ? "bell.fill" : "bell.slash.fill")
                                .foregroundColor(.white)
                        )
                }

                Slider(value: $soundVolume, in: 0...1)
                    .accentColor(.accent1)
                    .disabled(!soundEnabled)
                    .onChange(of: soundVolume) { newVolume in
                        // In futuro: aggiorna volume effetti sonori
                    }
            }*/

            // Vibrazione
            /*HStack {
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
            }*/

            // Mano preferita
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
            // Tutorial & Credits
            VStack(spacing: 25) {
                NavigationLink(destination: TutorialIntroView()) {
                    Text("Tutorial")
                        .font(.title)
                        .bold()
                }
                Link("Credits", destination: URL(string: "https://sites.google.com/view/rakogame/home-page")!)
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
