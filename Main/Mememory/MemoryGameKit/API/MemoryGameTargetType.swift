//
//  MemoryGameTargetType.swift
//  MemoryGame
//

import Moya

protocol MemoryGameTargetType: TargetType {}

extension MemoryGameTargetType {
    
    public var clientId: String { return "i71BoBoxTxlbVYvnt7O2reL86DynpqT3" }
    public var clientSecret: String { return "i71BoBoxTxlbVYvnt7O2reL86DynpqT3" }
    public var baseURL: URL { return URL(string: "http://api.soundcloud.com/")! }
} 
