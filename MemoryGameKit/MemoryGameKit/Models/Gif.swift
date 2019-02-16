//
//  Gif.swift
//  MemoryGame
//

public struct Gif: Decodable {
    public var id: String
    public var images: Images
    
    public init(id: String, images: Images) {
        self.id = id
        self.images = images
    }
}

public struct Images: Decodable {
    public var previewGif: PreviewGif
    
    public init(previewGif: PreviewGif) {
        self.previewGif = previewGif
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ImagesKeys.self)
        previewGif = try container.decode(PreviewGif.self, forKey: .previewGif)
    }
    
    private enum ImagesKeys: String, CodingKey {
        case previewGif = "preview_gif"
    }
}


public struct PreviewGif: Decodable {
    public var url: String
    public var width: String
    public var height: String
    
    public init(url: String, width: String, height: String) {
        self.url = url
        self.width = width
        self.height = height
    }
}
