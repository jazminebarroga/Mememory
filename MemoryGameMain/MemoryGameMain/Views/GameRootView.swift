//
//  GameRootView.swift
//  MemoryGame
//

import UIKit
import RxDataSources
import RxSwift
import MemoryGameUIKit

class GameRootView: ProgrammaticView {
    
    let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.hidesWhenStopped = true
        view.color = .black
        return view
    }()
    
    let emptyView: UILabel = {
        let view = UILabel()
        view.numberOfLines = 2
        view.text = "Uh-oh, there are no tracks found from the API"
        view.isHidden = true
        return view
    }()
    
    let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(GameCollectionViewCell.self, forCellWithReuseIdentifier: GameCollectionViewCell.reuseIdentifier) 
        collectionView.backgroundColor = .white
        collectionView.isUserInteractionEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isHidden = true
        return collectionView
    }()
    
    private let viewModel: GameViewModel
    
    private let disposeBag = DisposeBag()
    
    init(frame: CGRect = .zero, viewModel: GameViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        setupViews()
    }
    
    private func setupViews() {
        setupEmptyView()
        setupActivityIndicator()
        setupCollectionView()
        bindDataSource()
    }
    
    private func setupEmptyView() {
        addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    private func setupActivityIndicator() {
        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    private func setupCollectionView() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionView.delegate = self
    }
    
    private func bindDataSource() {
        
        viewModel.sectionModels.asObservable()
            .bind(to: collectionView.rx.items(dataSource: configureCell()))
            .disposed(by: disposeBag)
    }

    private func configureCell() -> RxCollectionViewSectionedReloadDataSource<GameSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<GameSectionModel>(configureCell: { [weak self]
            (dataSource, collectionView, indexPath, cellViewModel) -> UICollectionViewCell in
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                GameCollectionViewCell.reuseIdentifier, for: indexPath) as? GameCollectionViewCell {
                self?.configureGameItem(with: cell, gameCellViewModel: cellViewModel)
                return cell
            } else {
                fatalError("\(GameCollectionViewCell.reuseIdentifier) not found in CollectionView")
            }
        })
    }
    
    private func configureGameItem(with cell: GameCollectionViewCell, gameCellViewModel: GameCellViewModel) {
        cell.viewModel = gameCellViewModel
    }
}

extension GameRootView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width/CGFloat(viewModel.gameSettings.gridLength) - 8, height: collectionView.bounds.size.height/CGFloat(viewModel.gameSettings.gridLength) - 8)
    }
}


