//
//  TrendingAPI.swift
//  MemoryGame
//

import Moya

public enum TrendingAPI {
    case getGifs(limit: Int, rating: Rating)
}

extension TrendingAPI: GifsTargetType {
    public var method: Moya.Method {
       return .get
    }
    var parameterEncoding: ParameterEncoding {
        return URLEncoding()
    }
    
    var parameters: [String: Any] {
        var parameters = [String: Any]()
        switch self {
        case .getGifs(let limit, let rating):
            parameters["api_key"] = apiKey
            parameters["limit"] = limit
            parameters["rating"] = rating.rawValue
        }
    
        return parameters
    }
    
    public var sampleData: Data {
        return Data() 
    }
    
    
    public var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    public var path: String {
        switch self {
        case .getGifs:
            return "trending"

        }
    }
    
    
}

