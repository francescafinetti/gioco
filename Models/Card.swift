//
//  ContentView.swift
//  gioco
//
//  Created by Francesca Finetti on 08/05/25.
//

import Foundation

struct Card: Identifiable, Equatable {
    let id = UUID()
    let value: String
    let suit: String
    
    var imageName: String {
        return "\(value)_di_\(suit)"
    }

    var isWinningCard: Bool {
        return value == "1" || value == "2" || value == "3"
    }

    var rankNumber: Int {
        switch value {
        case "1": return 1
        case "2": return 2
        case "3": return 3
        case "4": return 4
        case "5": return 5
        case "6": return 6
        case "7": return 7
        case "8": return 8
        case "9": return 9
        case "10": return 10
        default: return 0
        }
    }
}
