//
//  Track.swift
//  MemoryGame
//

public struct Track: Decodable {
    var id: Int
    var artworkUrl: String
    
    public init(id: Int, artworkUrl: String) {
        self.id = id
        self.artworkUrl = artworkUrl
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TrackKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        artworkUrl = try container.decode(String.self, forKey: .artworkUrl)
    }
    
    private enum TrackKeys: String, CodingKey {
        case id
        case artworkUrl = "artwork_url"
    }
}

