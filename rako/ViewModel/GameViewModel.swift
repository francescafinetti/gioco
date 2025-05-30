//
//  ContentView.swift
//  gioco
//
//  Created by Francesca Finetti on 08/05/25.
//

import Foundation
import SwiftUI

class GameViewModel: ObservableObject {
    @Published var players: [[Card]] = []
    @Published var centralPile: [Card] = []
    @Published var currentPlayer = 0
    @Published var winner: Int? = nil
    @Published var message: String = ""
    @Published var isGameOver: Bool = false
    @Published var botPlayCount = 0
    @Published var cardPlayCount = 0  // Conta tutte le carte giocate (bot e giocatore)
    @Published var lastCollector: Int? = nil  // 0 = player, 1 = bot

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

        print("Game started with \(playerCount) players")

        isGameOver = false
        lastCollector = nil

      
    }

    func playCard() {
        print("Player \(currentPlayer + 1) is about to play a card.")
        guard winner == nil else {
            print("Game already finished. Ignoring play.")
            return
        }
        guard !players[currentPlayer].isEmpty else {
            print("Player \(currentPlayer + 1) has no cards left.")
            checkWinner()
            return
        }


        let card = players[currentPlayer].removeFirst()
        print("Player \(currentPlayer + 1) played card: \(card.value)")

        centralPile.append(card)
        print("Central pile now has \(centralPile.count) cards.")
        doppiaContesa = false

        if forcedPlaysRemaining > 0 {
            forcedPlaysRemaining -= 1
            print("Forced plays remaining: \(forcedPlaysRemaining)")

            if card.isWinningCard {
                forcedPlaysRemaining = card.rankNumber
                print("Forced plays reset to \(forcedPlaysRemaining) due to winning card")
                currentPlayer = (currentPlayer + 1) % players.count
                autoPlayIfNeeded()
                return
            }
            if forcedPlaysRemaining == 0 {
                let winnerPlayer = (currentPlayer + 1) % players.count

                print("Forced play phase ended, player \(winnerPlayer + 1) collects central pile of \(centralPile.count) cards.")
                players[winnerPlayer].append(contentsOf: centralPile)
                centralPile.removeAll()

                if players[currentPlayer].isEmpty {
                    winner = winnerPlayer
                    isGameOver = true
                    message = "🎉 Player \(winnerPlayer + 1) won!"
                    print(message)
                    return

                }

                currentPlayer = winnerPlayer
                autoPlayIfNeeded()
                return
            }

            if players[currentPlayer].isEmpty {
                let otherPlayer = (currentPlayer + 1) % players.count
                print("Player \(currentPlayer + 1) finished cards early, player \(otherPlayer + 1) collects central pile")
                players[otherPlayer].append(contentsOf: centralPile)
                centralPile.removeAll()
                winner = otherPlayer
                isGameOver = true
                message = "🎉 Player \(otherPlayer + 1) won!"
                print(message)
                return
            }

        } else if card.isWinningCard {
            forcedPlaysRemaining = card.rankNumber
            print("New forced play phase started with \(forcedPlaysRemaining) forced plays.")
            currentPlayer = (currentPlayer + 1) % players.count
            autoPlayIfNeeded()
            return
        } else {
            currentPlayer = (currentPlayer + 1) % players.count
        }

        if players[currentPlayer].isEmpty {
            let other = (currentPlayer + 1) % players.count
            print("Player \(currentPlayer + 1) has no cards left. Player \(other + 1) wins!")
            if !centralPile.isEmpty {
                print("Player \(other + 1) collects central pile of \(centralPile.count) cards.")
                players[other].append(contentsOf: centralPile)
                centralPile.removeAll()
            }
            winner = other
            isGameOver = true
            message = "🎉 Player \(other + 1) won!"
            print(message)
            return
        }


        autoPlayIfNeeded()

        if isCPUEnabled {
            checkForBotDoppia()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.checkWinner()
        }

    }

    func tapForDoppia(by playerIndex: Int) {
        print("Player \(playerIndex + 1) tapped for doppia")
        guard centralPile.count >= 2 else { return }
        let last = centralPile[centralPile.count - 1]
        let secondLast = centralPile[centralPile.count - 2]
        if last.value == secondLast.value && !doppiaContesa {
            print("Doppia detected by player \(playerIndex + 1), collecting central pile")
            doppiaContesa = true
            lastCollector = playerIndex
            players[playerIndex].append(contentsOf: centralPile)
            centralPile.removeAll()
            currentPlayer = playerIndex
            forcedPlaysRemaining = 0
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
        guard isCPUEnabled, centralPile.count >= 2 else { return }
        let last = centralPile[centralPile.count - 1]
        let secondLast = centralPile[centralPile.count - 2]
        if last.value == secondLast.value && !doppiaContesa {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                guard self.isCPUEnabled else { return }
                if !self.doppiaContesa &&
                   self.centralPile[self.centralPile.count - 1].value ==
                   self.centralPile[self.centralPile.count - 2].value {
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
    }

  

       func checkWinner() {
        for (index, player) in players.enumerated() {
            if player.isEmpty {
                let other = (index + 1) % players.count
                if !centralPile.isEmpty {
                    print("Game over detected in checkWinner. Player \(other + 1) collects central pile of \(centralPile.count) cards.")
                    players[other].append(contentsOf: centralPile)
                    centralPile.removeAll()
                }
                winner = other
                message = "🎉 Player \(other + 1) won!"
                isGameOver = true
                print(message)
                return
            }
        }
    }
}
