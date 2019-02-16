//
//  PlaylistRepository.swift
//  MemoryGame
//

import Foundation
import RxSwift

public protocol PlaylistRepository {
    func fetchTracks(of playlistId: Int) -> Observable<GameLoadingState>
}
