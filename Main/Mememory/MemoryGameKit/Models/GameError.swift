//
//  ErrorMessage.swift
//  MemoryGame
//

import Foundation

public enum GameError {
    case notEnoughTracks
    case apiError(_ error: Error?)
    case unknown
    
    var message: String {
        switch self {
        case .notEnoughTracks:
            return "Uh oh, the API does not have enough tracks"
        case .apiError(let error):
            return "\(error?.localizedDescription ?? "Something went wrong")"
        case .unknown:
            return "Something went wrong :("
        }
    }
}
