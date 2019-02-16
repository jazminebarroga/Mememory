//
//  GameCellViewModel.swift
//  MemoryGame
//

import Foundation
import RxDataSources
import RxSwift
import MemoryGameKit

enum CellState {
    case open
    case closed
    case completed
} 

public class GameCellViewModel {
    
    var cellIdentifier: Int
    var gif: Gif
    var state: BehaviorSubject<CellState>
    let gameStateSubject: BehaviorSubject<GameState>
    let disposeBag: DisposeBag

    
    init(gif: Gif, gameStateSubject: BehaviorSubject<GameState>, cellIdentifier: Int) {
        self.gif = gif
        self.state = BehaviorSubject<CellState>(value: .closed)
        self.gameStateSubject = gameStateSubject
        self.disposeBag = DisposeBag()
        self.cellIdentifier = cellIdentifier
        bindGameState()
    }

    func bindGameState() {
       gameStateSubject
            .subscribe(onNext: { [weak self] gameState in
                guard let `self` = self else { return }
                switch gameState {
                case .matchSuccess(let cardOne, let cardTwo):
                    self.matchSuccess(with: cardOne, and: cardTwo)
                case .matchFailed(let cardOne, let cardTwo):
                    self.matchFailed(with: cardOne, and: cardTwo)
                default: break
                }
            })
            .disposed(by: disposeBag)
    }
    

    private func matchSuccess(with cardOne: Gif, and cardTwo: Gif) {
        if gif.id == cardOne.id || gif.id == cardTwo.id {
            state.onNext(.completed)
            state.onCompleted()
        } else {
            state.onNext(.closed)
        }
    }
    
    private func matchFailed(with cardOne: Gif, and cardTwo: Gif) {
        if gif.id == cardOne.id || gif.id == cardTwo.id {
            self.state.onNext(.closed)
        }
    }
}

struct GameSectionModel {
    var items: [Item]
}

extension GameSectionModel: SectionModelType {
    typealias Item = GameCellViewModel
    
    init(original: GameSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}
