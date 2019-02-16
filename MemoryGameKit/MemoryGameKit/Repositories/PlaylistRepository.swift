//
//  PlaylistRepository.swift
//  MemoryGame
//

import Foundation
import RxSwift

public protocol TrendingGifsRepository {
    func fetchTrendingGifs(with limit: Int) -> Observable<GameLoadingState>
}
