//
//  PlaylistsAPI.swift
//  MemoryGame
//

import Moya

public enum PlaylistsAPI {
    case getTracks(playlistId: Int)
}

extension PlaylistsAPI: MemoryGameTargetType {
    public var method: Method {
       return .get
    }
    var parameterEncoding: ParameterEncoding {
        return URLEncoding()
    }
    
    var parameters: [String: Any] {
        var parameters = [String: Any]()
        parameters["client_id"] = clientId
        parameters["client_secret"] = clientSecret
        return parameters
    }
    
    public var sampleData: Data {
        return Data() //TODO
    }
    
    
    public var task: Task {
        return .requestParameters(parameters: parameters, encoding: parameterEncoding)
    }
    
    public var headers: [String : String]? {
        return nil
    }
    
    public var path: String {
        switch self {
        case .getTracks(let playlistId):
            return "playlists/\(playlistId)"

        }
    }
    
    
}

