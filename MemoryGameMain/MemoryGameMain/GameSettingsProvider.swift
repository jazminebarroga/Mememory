//
//  GameSettingsProvider.swift
//  MemoryGame
//

import Foundation

public protocol GameSettingsProvider {
    var gridLength: Int { get set }
    var dataNeeded: Int { get }
}

struct MemoryGameSettingsProvider: GameSettingsProvider {
    var gridLength: Int = 4
    var dataNeeded: Int {
        return gridLength * gridLength / 2
    }

}
