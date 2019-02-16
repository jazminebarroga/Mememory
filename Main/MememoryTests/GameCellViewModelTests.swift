//
// TrackCellViewModelTests.swift
//  MemoryGameTests


import XCTest
import RxTest
import RxSwift

import MemoryGameKit

@testable import MemoryGameMain

class GameCellViewModelTests: XCTestCase {

    var gameCellViewModel: GameCellViewModel!
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        gameCellViewModel = nil
        disposeBag = nil
        super.tearDown()
    }

    func testMatchSuccessShouldForwardCompleteCellState() {
        let scheduler = TestScheduler(initialClock: 0)
        let gifOneA = Gif(id: "1", images: Images(previewGif:    PreviewGif(url: "", width: "", height: "")))
        let gifOneB = Gif(id: "1", images: Images(previewGif:    PreviewGif(url: "", width: "", height: "")))
        
        let expectedCellStates: [Recorded<Event<CellState>>] = [
            next(200, .closed),
            next(220, .completed),
            completed(220)
        ]
        
        let gameState: Observable<GameState> = scheduler.createHotObservable([
            next(220, GameState.matchSuccess(cardOne: gifOneA, cardTwo: gifOneB)),
            next(230, GameState.matchSuccess(cardOne: gifOneA, cardTwo: gifOneB))
            ]).asObservable()
        
        let gameStateSubject = BehaviorSubject<GameState>(value: .idle)
        
        gameState
            .bind(to: gameStateSubject)
            .disposed(by: disposeBag)
        
        gameCellViewModel = GameCellViewModel(gif: gifOneA, gameStateSubject: gameStateSubject, cellIdentifier: 1)
        
        let events = scheduler.start {
            self.gameCellViewModel.state
        }.events
        
        XCTAssertEqual(events, expectedCellStates)
    }
    
    func testMatchSuccessShouldForwardCloseCellState() {
        let scheduler = TestScheduler(initialClock: 0)
        let gifOneA = Gif(id: "1", images: Images(previewGif:    PreviewGif(url: "", width: "", height: "")))
        let gifTwoA = Gif(id: "2", images: Images(previewGif: PreviewGif(url: "", width: "", height: "")))
        
        let expectedCellStates: [Recorded<Event<CellState>>] = [
            next(200, .closed),
            next(220, .closed)
            ]
        
        let gameState: Observable<GameState> = scheduler.createHotObservable([
            next(220, GameState.matchFailed(cardOne: gifOneA, cardTwo: gifTwoA))]).asObservable()
        
        let gameStateSubject = BehaviorSubject<GameState>(value: .idle)
        
        gameState
            .bind(to: gameStateSubject)
            .disposed(by: disposeBag)
        
        gameCellViewModel = GameCellViewModel(gif: gifOneA, gameStateSubject: gameStateSubject, cellIdentifier: 1)
        
        let events = scheduler.start {
            self.gameCellViewModel.state
            }.events
        
        XCTAssertEqual(events, expectedCellStates)
    }

}
