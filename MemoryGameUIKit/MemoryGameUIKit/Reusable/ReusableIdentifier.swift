//
//  ReusableIdentifier.swift
//  MemoryGameUIKit
//

import Foundation

public protocol ReusableIdentifier {
    static var reuseIdentifier: String { get }
}

public extension ReusableIdentifier {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}
