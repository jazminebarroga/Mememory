//
//  AppDependencyContainer.swift
//  MemoryGame
//

import Foundation
import Moya
import MemoryGameKit

public class AppDependencyContainer {
    
    public init() {}

    public func makeGameViewController() -> GameViewController {
        return GameViewController(gameViewModel: makeGameViewModel())
    }
    
    public func makeGameViewModel() -> GameViewModel {
        return GameViewModel(trendingGifsRepository: makeTrendingGifsRepository(), gameSettingsProvider: makeGameSettingsProvider())
    }
    
    public func makeGameSettingsProvider() -> GameSettingsProvider {
        return MemoryGameSettingsProvider()
    }
    
    public func makeTrendingGifsRepository() -> TrendingGifsRepository {
        return GameTrendingGifsRepository(provider: makeTrendingAPIProvider())
    }
    
    public func makeTrendingAPIProvider() -> MoyaProvider<TrendingAPI> {
        let networkPlugin = NetworkLoggerPlugin(cURL: true)

        return MoyaProvider<TrendingAPI>(plugins: [networkPlugin])
    }
}
