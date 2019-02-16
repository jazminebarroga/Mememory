//
//  GameViewModel.swift
//  MemoryGame
//

import Foundation
import RxSwift
import MemoryGameKit

struct GameStateConstants {
    static let matchSuccess = "matchSuccess"
    static let matchFailed = "matchFailed"
    static let idle = "idle"
    static let matchCompleted = "matchCompleted"
    static let matchStarted = "matchStarted"
}

enum GameState {
    case matchSuccess(cardOne: Gif, cardTwo: Gif)
    case matchFailed(cardOne: Gif, cardTwo: Gif)
    case idle
    case matchCompleted(cardOne: Gif, cardTwo: Gif)
    case matchStarted(cardOne: Gif)
    
    var description: String {
        switch self {
        case .matchSuccess: return GameStateConstants.matchSuccess
        case .matchFailed: return GameStateConstants.matchFailed
        case .idle: return GameStateConstants.idle
        case .matchCompleted: return GameStateConstants.matchCompleted
        case .matchStarted: return GameStateConstants.matchStarted
        }
    }
}

public class GameViewModel {
        
    private let trendingGifsRepository: TrendingGifsRepository
    
    let loadingState = PublishSubject<GameLoadingState>()
    
    private var gifs: Observable<[Gif]> {
        return trendingSubject
            .map({ trending -> [Gif]? in
                return trending?.data
            })
            .flatMap { Observable.from(optional: $0) }
            .mapToGameData(amountDataNeeded: amountDataNeeded)
    }
    
    let newGame = PublishSubject<Bool>()
    
    private let shuffledGifs = PublishSubject<[Gif]>()

    var sectionModels: Observable<[GameSectionModel]> {
        return cellViewModels
            .map { [GameSectionModel(items: $0)] }
    }
  
    let gameStateSubject = BehaviorSubject<GameState>(value: .idle)
    
    private var cellViewModels: Observable<[GameCellViewModel]> {
       return shuffledGifs
        .map({ (gifs) -> [GameCellViewModel] in
            var count = -1
            return gifs.map({ gif -> GameCellViewModel in
                count += 1
                return GameCellViewModel(gif: gif, gameStateSubject: self.gameStateSubject, cellIdentifier: count)
            })
        })
    }

    private let trendingSubject = BehaviorSubject<Trending?>(value: nil)
    
    let errors = PublishSubject<GameError>()
    
    private let disposeBag = DisposeBag()

    private let compareMatch = PublishSubject<(Gif, Gif)>()
    
    private var amountDataNeeded: Int {
        return (gameSettings.gridLength * gameSettings.gridLength) / 2
    }
    
    private var isAMatch: Observable<Bool> {
        return gameStateSubject
            .map { $0.description }
            .filter { $0 == GameStateConstants.matchSuccess }
            .map({ success -> Bool in
                return true
            })
    }
    
    private var numCardsPaired: Observable<Int> {
        return isAMatch
            .filter { $0 == true }
            .take(gameSettings.dataNeeded)
            .scan(0, accumulator: { (currentNumberCardsPaired, isAMatch) -> Int in
                return currentNumberCardsPaired + 2
            })
        
    }
    
    var isGameCompleted: Observable<Bool> {
        return numCardsPaired
            .map { $0 == self.gameSettings.gridLength * self.gameSettings.gridLength }
    }
    
    let gameSettings: GameSettingsProvider
    
    init(trendingGifsRepository: TrendingGifsRepository, gameSettingsProvider: GameSettingsProvider) {
        self.trendingGifsRepository = trendingGifsRepository
        self.gameSettings = gameSettingsProvider
        setupTrackBindings()
        setupGameStateHandlers()
        setupCompareMatchHandler()
    }

    func loadTrendingGifs() {
        trendingGifsRepository.fetchTrendingGifs(with: gameSettings.dataNeeded)
            .subscribe(onNext: { [weak self] loadingState in
                guard let `self` = self else { return }
                switch loadingState {
                case .started:
                    self.loadingState.onNext(loadingState)
                case .completed(let list):
                    guard let trending = list, trending.data.count >= self.amountDataNeeded else {
                        self.errors.onNext(.notEnoughTracks)
                        return
                    }
                    
                    self.loadingState.onNext(loadingState)
                    self.trendingSubject.onNext(trending)
                case .error(let error):
                   self.loadingState.onNext(loadingState)
                   self.errors.onNext(error)
                }
            })
            .disposed(by: disposeBag)

    }
    
    func setupGameStateHandlers() {
        gameStateSubject
            .subscribe(onNext: { [weak self] gameState in
                guard let `self` = self else { return }
                switch gameState {
                case .matchCompleted(let cardOne, let cardTwo):
                    self.compareMatch.onNext((cardOne, cardTwo))
                default: break
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setupCompareMatchHandler() {
        compareMatch
            .delay(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] (cardOne, cardTwo) in
                guard let `self` = self else { return }
                if cardOne.id == cardTwo.id {
                    self.gameStateSubject.onNext(.matchSuccess(cardOne: cardOne, cardTwo: cardTwo))
                } else {
                    self.gameStateSubject.onNext(.matchFailed(cardOne: cardOne, cardTwo: cardTwo))
                }
            })
            .disposed(by: disposeBag)
    }
    
    func setupTrackBindings() {
        gifs
        .map { $0.shuffled()}
        .bind(to: shuffledGifs)
        .disposed(by: disposeBag)
        
        newGame.asObservable()
            .filter { $0 == true }
            .withLatestFrom(gifs)
            .subscribe(onNext: { [weak self] gifs in
                guard let `self` = self else { return }
                self.gameStateSubject.onNext(.idle)
                self.shuffledGifs.onNext(gifs.shuffled())
             })
            .disposed(by: disposeBag)
    }
}

extension ObservableType where E == [Gif] {
    func mapToGameData(amountDataNeeded: Int) -> Observable<[Gif]> {
        return self.map { gifs -> [Gif] in
            var truncatedGifs = Array(gifs.prefix(amountDataNeeded))
            truncatedGifs.append(contentsOf: truncatedGifs)
            return truncatedGifs
        }
    }
}
