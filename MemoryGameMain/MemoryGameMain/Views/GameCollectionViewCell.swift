//
//  GameCollectionViewCell.swift
//  MemoryGame
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import MemoryGameUIKit
import Kingfisher

class GameCollectionViewCell: UICollectionViewCell, ReusableIdentifier {

    private let disposeBag = DisposeBag()
    
    override var reuseIdentifier: String? {
        return "GameCollectionViewCell"
    }
    
    var viewModel: GameCellViewModel? {
        didSet {
            guard let viewModel = viewModel,  let url = URL(string: viewModel.gif.images.previewGif.url) else { return }
            imageView.kf.setImage(with: url)
            setupState()
        }
    }
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private let coverView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "giphy")
        view.contentMode = .scaleAspectFit
        view.backgroundColor = .black
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
        setupCoverView()
        backgroundColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupCoverView() {
        insertSubview(coverView, aboveSubview: imageView)
        coverView.snp.makeConstraints { make in
            make.edges.equalTo(imageView.snp.edges)
        }
    }
    private func setupState() {
        guard let `viewModel` = viewModel else { return }
        
        
        viewModel.state.asObservable()
            .observeOn(MainScheduler.instance)
            .map { $0 != .closed }
            .bind(to: coverView.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewModel.state.asDriver(onErrorJustReturn: .closed)
            .drive(onNext: { [weak self] requestedState in
                guard let `self` = self else { return }
                switch requestedState {
                case .open:
                    self.isUserInteractionEnabled = false
                case .closed:
                    self.isUserInteractionEnabled = true
                case .completed:
                    self.isUserInteractionEnabled = false
                }
            })
            .disposed(by: disposeBag)

    }
    
}

