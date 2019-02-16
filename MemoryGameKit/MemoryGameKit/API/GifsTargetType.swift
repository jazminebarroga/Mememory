//
//  GifsTargetType
//  MemoryGame
//

import Moya

protocol GifsTargetType: TargetType {}

extension GifsTargetType {
    
    public var apiKey: String {
        return "INSTALL_YOUR_API_KEY_HERE"
    }
    public var baseURL: URL {
        guard let url = URL(string: "https://api.giphy.com/v1/gifs/") else {
            fatalError("Given url string cannot be converted to URL")
        }
        return url
    }

   
} 
