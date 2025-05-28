//
//  Untitled.swift
//  gioco
//
//  Created by Francesca Finetti on 26/05/25.
//

import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var player: AVAudioPlayer?

    func startBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "homeview1", withExtension: "mp3") else {
            print("🎵 File audio non trovato")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // loop infinito
            player?.volume = 0.5
            player?.play()
        } catch {
            print("Errore nella riproduzione audio: \(error)")
        }
    }

    func stopBackgroundMusic() {
        player?.stop()
    }
}
