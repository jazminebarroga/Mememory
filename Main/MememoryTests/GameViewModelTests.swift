//
//  GameViewModelTests.swift
//  MemoryGameTests
//


import XCTest
import RxTest
import RxSwift

import MemoryGameKit
@testable import MemoryGameMain

class GameViewModelTests: XCTestCase {

    var gameViewModel: GameViewModel!
    
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        gameViewModel = nil
        disposeBag = nil
        super.tearDown()
    }

    func testStartingANewGameShouldResetGameState() {
        let mockTrendingGifsRepository = GoodMockTrendingGifsRepository()
        let gameSetttingsProvider = MockGameSettingsProvider()
        gameViewModel = GameViewModel(trendingGifsRepository: mockTrendingGifsRepository, gameSettingsProvider: gameSetttingsProvider)
        
        let scheduler = TestScheduler(initialClock: 0)
        
        let expectedGameStates = "t=200: idle -- t=220: idle"
        
        scheduler.scheduleAt(210) {
            self.gameViewModel.loadTrendingGifs()
        }
        
        scheduler.scheduleAt(220) {
            self.gameViewModel.newGame.onNext(true)
        }
        
        let events = scheduler.start {
            self.gameViewModel.gameStateSubject
            }.events
        
        let result = events.map { "t=\($0.time): \($0.value.element?.description ?? "??")"}.joined(separator: " -- ")
        
        XCTAssertEqual(result, expectedGameStates)
    }
    
    func testStartingANewGameShouldProduceASetOfPairedTracks() {
        let mockTrendingGifsRepository = GoodMockTrendingGifsRepository()
        let gameSetttingsProvider = MemoryGameSettingsProvider()
        gameViewModel = GameViewModel(trendingGifsRepository: mockTrendingGifsRepository, gameSettingsProvider: gameSetttingsProvider)
        let scheduler = TestScheduler(initialClock: 0)
       
        scheduler.scheduleAt(210) {
          self.gameViewModel.loadTrendingGifs()
        }
        
        scheduler.scheduleAt(220) {
            self.gameViewModel.newGame.onNext(true)
        }
        
        let events = scheduler.start {
            self.gameViewModel.sectionModels
        }.events

        guard events.count == 2, let sectionModel = events[0].value.element?[0] else {
            XCTFail("Expected event count is 2, found \(events.count)")
            return
        }
        
        var pairsFound = 0
        var cellVisited = Array(repeating: false, count: sectionModel.items.count)
        
        for index in 0..<sectionModel.items.count {
            let item = sectionModel.items[index]
            let id = item.gif.id
            cellVisited[index] = true
            
            for i in 0..<sectionModel.items.count {
                if !cellVisited[i] && id == sectionModel.items[i].gif.id {
                    cellVisited[i] = true
                    pairsFound += 1
                }
            }
        }
        XCTAssertEqual(pairsFound, 8)
    }
    
    func testGameShouldReturnErrorIfDataIsIncomplete() {
        let mockTrendingGifsRepository = BadMockTrendingGifsRepository()
        let gameSetttingsProvider = MemoryGameSettingsProvider()
        gameViewModel = GameViewModel(trendingGifsRepository: mockTrendingGifsRepository, gameSettingsProvider: gameSetttingsProvider)
        
        let promise = expectation(description: "errors should receive an error if data is not enough to build the gridLength provided in the game settings")
        let expectedErrorStateEvents = "t=100: notEnoughTracks"

        let scheduler = TestScheduler(initialClock: 0)
        let testObserver = scheduler.createObserver(GameError.self)

        scheduler.scheduleAt(1) {
            self.gameViewModel.errors
                .do(onNext: { gameError in
                    promise.fulfill()
                })
                .subscribe(testObserver)
                .disposed(by: self.disposeBag)
        }
        
        scheduler.scheduleAt(100) {
            self.gameViewModel.loadTrendingGifs()
        }
        
        scheduler.start()
        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
           let result = testObserver.events.map { "t=\($0.time): \($0.value.element?.description ?? "??")"}.joined(separator: " -- ")
            XCTAssertEqual(result, expectedErrorStateEvents)
        }
    }
    
    func testIsGameCompletedShouldBeBasedFromNumberOfCardsSuccessfullyPaired() {
        
        let mockTrendingGifsRepository = GoodMockTrendingGifsRepository()
        let gameSetttingsProvider = MockGameSettingsProvider()
        gameViewModel = GameViewModel(trendingGifsRepository: mockTrendingGifsRepository, gameSettingsProvider: gameSetttingsProvider)
        
        let scheduler = TestScheduler(initialClock: 0)
        let gifOneA = Gif(id: "1", images: Images(previewGif:    PreviewGif(url: "", width: "", height: "")))
        let gifOneB = Gif(id: "1", images: Images(previewGif:    PreviewGif(url: "", width: "", height: "")))
        
        let expectedIsGameCompletedEvents:  [Recorded<Event<Bool>>] = [
            next(220, false),
            next(230, true),
            completed(230)
        ]
        
        let gameStateObs: Observable<GameState> = scheduler.createHotObservable([
            next(220, GameState.matchSuccess(cardOne: gifOneA, cardTwo: gifOneB)),
            next(230, GameState.matchSuccess(cardOne: gifOneA, cardTwo: gifOneB)),
            next(240, GameState.matchSuccess(cardOne: gifOneA, cardTwo: gifOneB))
            ]).asObservable()
        
        gameStateObs
            .bind(to: gameViewModel.gameStateSubject)
            .disposed(by: disposeBag)
        
        let events = scheduler.start {
            self.gameViewModel.isGameCompleted
        }.events

        XCTAssertEqual(events, expectedIsGameCompletedEvents)
    }
    
    
    func testCompareMatchShouldEvaluateMatchesSuccessfully() {
        
        let mockTrendingGifsRepository = GoodMockTrendingGifsRepository()
        let gameSetttingsProvider = MockGameSettingsProvider()
        gameViewModel = GameViewModel(trendingGifsRepository: mockTrendingGifsRepository, gameSettingsProvider: gameSetttingsProvider)
        
        let promise = expectation(description: "compareMatch should evaluate tracks successfully and forward results to gameStateSubject")
        let expectedGameStateEvents = "t=1: idle -- t=220: matchCompleted -- t=230: matchCompleted -- t=230: matchSuccess -- t=230: matchFailed"
        
        let scheduler = TestScheduler(initialClock: 0)
        let testObserver = scheduler.createObserver(GameState.self)
        
        let gifOneA = Gif(id: "1", images: Images(previewGif:    PreviewGif(url: "", width: "", height: "")))
        let gifOneB = Gif(id: "1", images: Images(previewGif:    PreviewGif(url: "", width: "", height: "")))
        let gifTwoA = Gif(id: "2", images: Images(previewGif:    PreviewGif(url: "", width: "", height: "")))
        
        scheduler.scheduleAt(1) {
            self.gameViewModel.gameStateSubject
                .subscribe(testObserver)
                .disposed(by: self.disposeBag)
            
            
            self.gameViewModel.gameStateSubject
                .scan(0, accumulator: { (count, gameState) -> Int in
                    var tempCount = count
                    switch gameState {
                    case .matchSuccess: tempCount += 1
                    case .matchFailed:  tempCount += 1
                    default:  break
                    }
                    if tempCount == 2 {
                        promise.fulfill()
                    }
                    return tempCount
                })
                .subscribe()
                .disposed(by: self.disposeBag)
        }
        
        let gameStateObs: Observable<GameState> = scheduler.createHotObservable([
            next(220, GameState.matchCompleted(cardOne: gifOneA, cardTwo: gifOneB)),
            next(230, GameState.matchCompleted(cardOne: gifOneA, cardTwo: gifTwoA))
            ]).asObservable()
        
        
        gameStateObs
            .bind(to: gameViewModel.gameStateSubject)
            .disposed(by: disposeBag)
        
        scheduler.start()
        
        waitForExpectations(timeout: 5) { error in
            XCTAssertNil(error)
            let result = testObserver.events.map { "t=\($0.time): \($0.value.element?.description ?? "??")"}.joined(separator: " -- ")
            XCTAssertEqual(result, expectedGameStateEvents)
            
        }
    }
}

private class GoodMockTrendingGifsRepository: TrendingGifsRepository {

    func fetchTrendingGifs(with limit: Int)-> Observable<GameLoadingState> {
    guard let sampleGoodTrendingGifs = UnitTestUtilities.getGoodTrendingGifs() else { fatalError("Failed to parse sample playlist from getGoodTrendingGifs.json") }
        return Observable.just(.completed(trending: sampleGoodTrendingGifs))
    }
}

private class BadMockTrendingGifsRepository: TrendingGifsRepository {
    func fetchTrendingGifs(with limit: Int) -> Observable<GameLoadingState> {
        guard let sampleBadTrendingGifs = UnitTestUtilities.getBadTrendingGifs() else { fatalError("Failed to parse sample trendingGifs from getBadTrendingGifs.json") }
        return Observable.just(.completed(trending: sampleBadTrendingGifs))
    }
}

private class MockGameSettingsProvider: GameSettingsProvider {
    var dataNeeded: Int = 2
    
    var gridLength: Int = 2
}
