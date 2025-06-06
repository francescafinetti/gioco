//
//  ContentView.swift
//  gioco
//
//  Created by Francesca Finetti on 08/05/25.
//
//
//  GameViewModel.swift
//  gioco
//

import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    
    @Published var showStarAnimation = false
    @Published var players: [[Card]] = []
    @Published var centralPile: [Card] = []
    @Published var currentPlayer = 0
    @Published var winner: Int? = nil
    @Published var message: String = ""
    @Published var isGameOver: Bool = false
    @Published var botPlayCount = 0
    @Published var cardPlayCount = 0          // Conta tutte le carte giocate
    @Published var lastCollector: Int? = nil   // 0 = player, 1 = bot
    @Published var isUserSlapping = false      // Blocca il bot mentre l’utente slappa

    private let values = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    private let suits = ["arancione", "viola", "blu", "giallo"]

    private var forcedPlaysRemaining = 0
    private var doppiaContesa = false
    private let isCPUEnabled: Bool

    init(playerCount: Int = 2, isCPUEnabled: Bool = true) {
        self.isCPUEnabled = isCPUEnabled
        startGame(playerCount: playerCount)
    }

    func startGame(playerCount: Int) {
        botPlayCount = 0
        cardPlayCount = 0
        lastCollector = nil
        isUserSlapping = false

        var deck: [Card] = []
        for suit in suits {
            for value in values {
                deck.append(Card(value: value, suit: suit))
            }
        }
        deck.shuffle()

        let perPlayer = deck.count / playerCount
        players = []
        for i in 0..<playerCount {
            let start = i * perPlayer
            let end = start + perPlayer
            players.append(Array(deck[start..<end]))
        }

        centralPile = []
        currentPlayer = 0
        winner = nil
        message = ""
        forcedPlaysRemaining = 0
        doppiaContesa = false
        isGameOver = false
    }

    func playCard() {
        guard winner == nil else { return }
        guard !players[currentPlayer].isEmpty else {
            checkWinner()
            return
        }

        let card = players[currentPlayer].removeFirst()

        if isCPUEnabled && currentPlayer == 1 {
            botPlayCount += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.centralPile.append(card)
                self.doppiaContesa = false
                self.cardPlayCount += 1
                self.postCardPlacement()
            }
        } else {
            centralPile.append(card)
            doppiaContesa = false
            cardPlayCount += 1
            postCardPlacement()
        }
    }

    private func postCardPlacement() {
        if let last = centralPile.last,
              ["1", "2", "3"].contains(last.value) {
               showStarAnimation = true
               DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                   self.showStarAnimation = false
               }
           }
        
        if forcedPlaysRemaining > 0 {
            forcedPlaysRemaining -= 1
            if centralPile.last!.isWinningCard {
                forcedPlaysRemaining = centralPile.last!.rankNumber
                currentPlayer = (currentPlayer + 1) % players.count
                autoPlayIfNeeded()
                return
            }
            if forcedPlaysRemaining == 0 {
                let winnerPlayer = (currentPlayer + 1) % players.count
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        // Qui l’avversario ha già buttato tutte le carte obbligate:
                        self.players[winnerPlayer].append(contentsOf: self.centralPile)
                        self.centralPile.removeAll()
                        self.checkWinner()
                        self.currentPlayer = winnerPlayer
                        self.autoPlayIfNeeded()
                        // Ritardo di 0.25s per far completare la transizione .scale dell’ultima carta
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            self.lastCollector = winnerPlayer
                            // Pulisco subito dopo un brevissimo flash (per evitare ripetizioni)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.lastCollector = nil
                            }
                        }
                    }
                }
                return
            }
        } else if centralPile.last!.isWinningCard {
            forcedPlaysRemaining = centralPile.last!.rankNumber
            currentPlayer = (currentPlayer + 1) % players.count
            autoPlayIfNeeded()
            return
        } else {
            currentPlayer = (currentPlayer + 1) % players.count
        }

        if players[currentPlayer].isEmpty {
            checkWinner()
        } else {
            autoPlayIfNeeded()
        }

        if isCPUEnabled {
            checkForBotDoppia()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.checkWinner()
        }
    }

    func tapForDoppia(by playerIndex: Int) {
        guard centralPile.count >= 2 else { return }
        let last = centralPile[centralPile.count - 1]
        let secondLast = centralPile[centralPile.count - 2]
        if last.value == secondLast.value && !doppiaContesa {
            doppiaContesa = true
            lastCollector = playerIndex
            players[playerIndex].append(contentsOf: centralPile)
            centralPile.removeAll()
            currentPlayer = playerIndex
            forcedPlaysRemaining = 0
            
            NSObject.cancelPreviousPerformRequests(withTarget: self)
            checkWinner()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.lastCollector = nil
            }
        }
    }

    private func autoPlayIfNeeded() {
        guard isCPUEnabled else { return }
        if currentPlayer == 1 && winner == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.playCard()
            }
        }
    }

    private func checkForBotDoppia() {
        guard isCPUEnabled, !isUserSlapping, centralPile.count >= 2 else { return }
        let last = centralPile[centralPile.count - 1]
        let secondLast = centralPile[centralPile.count - 2]
        if last.value == secondLast.value && !doppiaContesa {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                guard self.isCPUEnabled,
                      !self.isUserSlapping,
                      self.centralPile.count >= 2 else { return }

                let topVal = self.centralPile[self.centralPile.count - 1].value
                let secVal = self.centralPile[self.centralPile.count - 2].value
                guard topVal == secVal && !self.doppiaContesa else { return }

                self.doppiaContesa = true
                self.lastCollector = 1
                self.players[1].append(contentsOf: self.centralPile)
                self.centralPile.removeAll()
                self.currentPlayer = 1
                self.forcedPlaysRemaining = 0
                self.checkWinner()
                self.autoPlayIfNeeded()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.lastCollector = nil
                }
            }
        }
    }

    func checkWinner() {
        for (index, player) in players.enumerated() {
            if player.isEmpty {
                let other = (index + 1) % players.count
                if !centralPile.isEmpty {
                    players[other].append(contentsOf: centralPile)
                    centralPile.removeAll()
                }
                winner = other
                message = "🎉 Player \(other + 1) won!"
                isGameOver = true
                return
            }
        }
    }
}
