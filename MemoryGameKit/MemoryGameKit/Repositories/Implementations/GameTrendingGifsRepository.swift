//
//  GamePlaylistRepository
//  MemoryGame
//

import Moya
import RxMoya
import RxSwift

public enum GameLoadingState {
    case started
    case completed(trending: Trending?)
    case error(_ error: GameError)
}

public class GameTrendingGifsRepository: TrendingGifsRepository {
    
    private let apiProvider: MoyaProvider<TrendingAPI>
    
    public init(provider: MoyaProvider<TrendingAPI>) {
        apiProvider = provider
    }
    
    public func fetchTrendingGifs(with limit: Int) -> Observable<GameLoadingState> {
        
        let observable = Observable<GameLoadingState>.create { [weak self] observer -> Disposable in
            guard let `self` = self else {
                return Disposables.create()
            }
            
        observer.onNext(.started)
            let subscription =
                self.apiProvider.rx
                .request(.getGifs(limit: limit, rating: .G))
                .map(Trending.self)
                .asObservable()
                .subscribe(onNext: { trending in
                    observer.onNext(.completed(trending: trending))
                    observer.onCompleted()
                }, onError: { error in
                    observer.onNext(.error(.apiError(error)))
                })
            return subscription
        }
        return observable
    }
}
