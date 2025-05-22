//
//  SettingsView.swift
//  gioco
//
//  Created by Francesca Finetti on 21/05/25.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("volumeEnabled") private var volumeEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    @AppStorage("isLeftHanded") private var isLeftHanded = false
    @AppStorage("difficulty") private var difficulty = "Medium"
    
    let difficulties = ["Easy", "Medium", "Hard"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sound & Feedback")) {
                    Toggle(isOn: $volumeEnabled) {
                        Label("Volume", systemImage: "speaker.wave.2.fill")
                    }
                    
                    Toggle(isOn: $vibrationEnabled) {
                        Label("Vibrations", systemImage: "iphone.radiowaves.left.and.right")
                    }
                }
                
                Section(header: Text("Preferences")) {
                    Picker("Mano dominante", selection: $isLeftHanded) {
                        Text("Left hand").tag(false)
                        Text("Right Hand").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(difficulties, id: \.self) {
                            Text($0)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}


#Preview {
       SettingsView()
    }
