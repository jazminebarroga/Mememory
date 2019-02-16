//
//  ProgrammaticView.swift
//  MemoryGame
//

import UIKit

open class ProgrammaticView: UIView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable,
    message: "Using nibs for views is not supported"
    )
    public required init?(coder aDecoder: NSCoder) {
        fatalError("Using nibs for views is not supported")
    }
}
