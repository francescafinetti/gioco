import SwiftUI
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()

    @AppStorage("musicVolume") private var musicVolume: Double = 0.5
    @AppStorage("volumeEnabled") private var volumeEnabled: Bool = true

    private var player: AVAudioPlayer?
    private var currentTrackName: String?
    private var fadeTimer: Timer?

    // MARK: - Public Functions

    func startBackgroundMusic() {
        fadeToMusic(named: "homeview", volume: Float(musicVolume))
    }

    func startGameMusic() {
        fadeToMusic(named: "gameview", volume: Float(musicVolume))
    }

    func stopBackgroundMusic() {
        if currentTrackName == "homeview" {
            stopMusic()
        }
    }

    func stopGameMusic() {
        if currentTrackName == "gameview" {
            stopMusic()
        }
    }

    func stopMusic() {
        player?.stop()
        currentTrackName = nil
    }

    func setCurrentVolume(to volume: Float) {
        player?.volume = volume
    }

    // MARK: - Fade & Transitions

    func fadeToMusic(named name: String, volume: Float = 0.5, delay: TimeInterval = 0.5) {
        guard volumeEnabled else { return }
        guard currentTrackName != name else { return }

        fadeOut(duration: 1.0) {
            self.stopMusic()
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.playMusic(named: name, volume: 0.0)
                self.fadeIn(to: volume, duration: 1.0)
            }
        }
    }

    private func fadeOut(duration: TimeInterval, completion: @escaping () -> Void) {
        fadeTimer?.invalidate()
        let steps = 20
        let interval = duration / Double(steps)
        var step = 0

        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if step >= steps {
                timer.invalidate()
                self.player?.volume = 0
                completion()
            } else {
                self.player?.volume -= Float(1.0 / Float(steps))
                step += 1
            }
        }
    }

    private func fadeIn(to targetVolume: Float, duration: TimeInterval) {
        fadeTimer?.invalidate()
        let steps = 20
        let interval = duration / Double(steps)
        var step = 0

        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            if step >= steps {
                timer.invalidate()
                self.player?.volume = targetVolume
            } else {
                self.player?.volume += (targetVolume / Float(steps))
                step += 1
            }
        }
    }

    // MARK: - Core Player

    private func playMusic(named name: String, volume: Float = 0.5) {
        guard volumeEnabled else { return }
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("🎵 File audio non trovato: \(name)")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = volume
            player?.prepareToPlay()
            player?.play()

            currentTrackName = name
        } catch {
            print("Errore nella riproduzione audio: \(error)")
        }
    }
}
