//
//  GameViewController.swift
//  MemoryGame
//

import UIKit
import RxSwift
import MemoryGameUIKit


public class GameViewController: ProgrammaticViewController {
    
    let gameViewModel: GameViewModel
    
    let disposeBag = DisposeBag()
    
    init(gameViewModel: GameViewModel) {
        self.gameViewModel = gameViewModel
        super.init()
    }
    
    public override func loadView() {
        view = GameRootView(viewModel: gameViewModel)
        view.backgroundColor = .white
        
        setupErrorMessagesRx()
        setupCollectionViewRx()
        setupLoadingState()
        loadTrendingGifs()
    }
    
    private func setupErrorMessagesRx() {
        gameViewModel.errors
            .asDriver(onErrorJustReturn: .unknown)
            .drive(onNext: { [weak view] gameError in
                guard let view = view as? GameRootView else { return }
                    view.emptyView.isHidden = false
                    view.collectionView.isHidden = true
                    view.emptyView.text = gameError.message
            })
            .disposed(by: disposeBag)
    }
    
    private func setupCollectionViewRx() {
        guard let view = view as? GameRootView else { return }
        
        view.collectionView.rx.modelSelected(GameCellViewModel.self)
            .withLatestFrom(self.gameViewModel.gameStateSubject, resultSelector: { (cellViewModel, gameState) -> (GameCellViewModel, GameState) in
                return (cellViewModel, gameState)
            })
            .subscribe(onNext: { [weak self] (cellViewModel, currentGameState) in
                guard let `self` = self else { return }
                
                switch currentGameState {
                case .matchSuccess,
                     .matchFailed,
                     .idle:
                
                    cellViewModel.state.onNext(.open)
                    self.gameViewModel.gameStateSubject.onNext(.matchStarted(cardOne: cellViewModel.gif))
                case .matchStarted(let cardOne):
                    cellViewModel.state.onNext(.open)
                    self.gameViewModel.gameStateSubject.onNext(.matchCompleted(cardOne: cardOne, cardTwo: cellViewModel.gif))
                    
                default: break
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setupGameCompletedRx() {
        gameViewModel.isGameCompleted
            .asDriver(onErrorJustReturn: false)
            .drive(onCompleted: { [weak self]  in
                guard let `self` = self else { return }
                let alert = UIAlertController(title: "Congratulations", message: "You have completed the game!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                alert.addAction(UIAlertAction(title: "Reset Game", style: .default, handler: { [weak self] _ in
                    self?.startNewGame()
                }))
                self.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func startNewGame() {
        gameViewModel.newGame.onNext(true)
        setupGameCompletedRx()
    }
    
    private func loadTrendingGifs(){
        gameViewModel.loadTrendingGifs()
    }
    
    private func setupLoadingState() {
        gameViewModel.loadingState
            .asDriver(onErrorJustReturn: .completed(trending: nil))
            .drive(onNext: { [weak self, weak view] loadingState in
                guard let `self` = self, let view = view as? GameRootView else { return }
                switch loadingState {
                case .started: view.activityIndicator.startAnimating()
                case .completed:
                    view.activityIndicator.stopAnimating()
                    view.emptyView.isHidden = true
                    view.collectionView.isHidden = false
                    self.startNewGame()
                case .error:
                    view.activityIndicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
    }
}

