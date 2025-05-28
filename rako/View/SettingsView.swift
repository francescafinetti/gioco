//
//  SettingsView.swift
//  gioco
//
//  Created by Francesca Finetti on 21/05/25.
//

import SwiftUI

struct SettingsCardView: View {
    @AppStorage("volumeEnabled") private var volumeEnabled = true
    @AppStorage("vibrationEnabled") private var vibrationEnabled = true
    @AppStorage("isLeftHanded") private var isLeftHanded = false
    @AppStorage("difficulty") private var difficulty = "Medium"

    let difficulties = ["Easy", "Medium", "Hard"]

    var body: some View {
        VStack(spacing: 12) {
            Toggle("Volume", isOn: $volumeEnabled)
            Toggle("Vibration", isOn: $vibrationEnabled)

            Picker("Hand", selection: $isLeftHanded) {
                Text("Left").tag(true)
                Text("Right").tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())

            Picker("Difficulty", selection: $difficulty) {
                ForEach(difficulties, id: \.self) { Text($0) }
            }
            .pickerStyle(SegmentedPickerStyle())

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}


#Preview {
       SettingsCardView()
    }

