//
//  GamePlaylistRepository
//  MemoryGame
//

import Moya
import RxMoya
import RxSwift

public enum GameLoadingState {
    case started
    case completed(playlist: Playlist?)
    case error(_ error: GameError)
}

class GamePlaylistRepository: PlaylistRepository {
    
    private let apiProvider: MoyaProvider<PlaylistsAPI>
    
    public init(provider: MoyaProvider<PlaylistsAPI>) {
        apiProvider = provider
    }
    
    func fetchTracks(of playlistId: Int) -> Observable<GameLoadingState> {
        
        let observable = Observable<GameLoadingState>.create { [weak self] observer -> Disposable in
            guard let `self` = self else {
                return Disposables.create()
            }
            
        observer.onNext(.started)
          let subscription = self.apiProvider.rx.request(.getTracks(playlistId: playlistId))
            .map(Playlist.self)
            .asObservable()
            .subscribe(onNext: { playlist in
                observer.onNext(.completed(playlist: playlist))
                observer.onCompleted()
            }, onError: { error in
                observer.onNext(.error(.apiError(error)))
            })
            return subscription
        }
        return observable
    }
}
