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

    private let values = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    private let suits = ["spade", "denari", "coppe", "bastoni"]

    private var forcedPlaysRemaining = 0
    private var doppiaContesa = false

    init(playerCount: Int = 2) {
        startGame(playerCount: playerCount)
    }

    func startGame(playerCount: Int) {
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
        forcedPlaysRemaining = 0
        doppiaContesa = false
        message = "Turno del giocatore 1"
    }

    func playCard() {
        guard winner == nil else { return }
        guard !players[currentPlayer].isEmpty else {
            checkWinner()
            return
        }

        let card = players[currentPlayer].removeFirst()
        centralPile.append(card)
        doppiaContesa = false
        message = "Giocatore \(currentPlayer + 1) ha giocato \(card.value.capitalized) di \(card.suit.capitalized)"

        if forcedPlaysRemaining > 0 {
            forcedPlaysRemaining -= 1
            if card.isWinningCard {
                forcedPlaysRemaining = card.rankNumber
                currentPlayer = (currentPlayer + 1) % players.count
                message += " – Carta vincente! Ora tocca al giocatore \(currentPlayer + 1) per \(forcedPlaysRemaining) carte."
                autoPlayIfNeeded()
                return
            }

            if forcedPlaysRemaining == 0 {
                let winnerPlayer = (currentPlayer + 1) % players.count
                message += " – Nessuna carta vincente! Il mazzo andrà al giocatore \(winnerPlayer + 1)..."

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.message += "\nGiocatore \(winnerPlayer + 1) prenderà il mazzo..."

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        self.players[winnerPlayer].append(contentsOf: self.centralPile)
                        self.centralPile.removeAll()
                        self.checkWinner()
                        self.message = "Giocatore \(winnerPlayer + 1) prende il mazzo!"
                        self.currentPlayer = winnerPlayer
                        self.autoPlayIfNeeded()
                    }
                }
                return
            }
        } else if card.isWinningCard {
            forcedPlaysRemaining = card.rankNumber
            currentPlayer = (currentPlayer + 1) % players.count
            message += " – Carta vincente! Ora tocca al giocatore \(currentPlayer + 1) per \(forcedPlaysRemaining) carte."
            autoPlayIfNeeded()
            return
        } else {
            currentPlayer = (currentPlayer + 1) % players.count
            message += "\nOra tocca al giocatore \(currentPlayer + 1)"
        }

        if players[currentPlayer].isEmpty {
            checkWinner()
        } else {
            autoPlayIfNeeded()
        }

        if currentPlayer != 1 {
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
            players[playerIndex].append(contentsOf: centralPile)
            centralPile.removeAll()
            message = "Giocatore \(playerIndex + 1) ha preso il mazzo con una doppia!"
            currentPlayer = playerIndex
            forcedPlaysRemaining = 0
            checkWinner()
        }
    }

    private func autoPlayIfNeeded() {
        if currentPlayer == 1 && winner == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.playCard()
            }
        }
    }

    private func checkForBotDoppia() {
        guard centralPile.count >= 2 else { return }

        let last = centralPile[centralPile.count - 1]
        let secondLast = centralPile[centralPile.count - 2]

        if last.value == secondLast.value {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                if !self.doppiaContesa &&
                    self.centralPile.count >= 2 &&
                    self.centralPile[self.centralPile.count - 1].value ==
                    self.centralPile[self.centralPile.count - 2].value {

                    self.doppiaContesa = true
                    self.players[1].append(contentsOf: self.centralPile)
                    self.centralPile.removeAll()
                    self.message = "🤖 Il bot ha preso il mazzo con una doppia!"
                    self.currentPlayer = 1
                    self.forcedPlaysRemaining = 0
                    self.checkWinner()
                    self.autoPlayIfNeeded()
                }
            }
        }
    }

    func checkWinner() {
        if let winnerIndex = players.firstIndex(where: { $0.count == 52 }) {
            winner = winnerIndex
            message = "🎉 Giocatore \(winnerIndex + 1) ha vinto!"
        }
    }
}

