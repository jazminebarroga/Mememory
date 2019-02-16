//
//  ProgrammaticViewController.swift
//  MemoryGame
//

import UIKit

open class ProgrammaticViewController: UIViewController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable,
    message: "Using nibs for views is not supported"
    )
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Using nibs for views is not supported")
    }
    
}
