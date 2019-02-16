//
//  UnitTestUtilities.swift
//  MemoryGameTests
//

import Foundation
import MemoryGameKit

class UnitTestUtilities {
    
   
    static func getGoodTrendingGifs() -> Trending? {

        let data = getData(from: "getGoodTrendingGifs")
        do {
            let trendingGifsSerialized = try JSONDecoder().decode(Trending.self, from: data)
            return trendingGifsSerialized
        } catch let error {
             print("\(error.localizedDescription)")
        }
        return nil
    }
    
    static func getBadTrendingGifs() -> Trending? {
        
        let data = getData(from: "getBadTrendingGifs")
        do {
            let trendingGifsSerialized = try JSONDecoder().decode(Trending.self, from: data)
            return trendingGifsSerialized
        } catch let error {
            print("\(error.localizedDescription)")
        }
        return nil
    }
    
    static func getData(from jsonFile: String) -> Data{
        let resourceBundle = Bundle(for: UnitTestUtilities.self)
        guard let json = resourceBundle.path(forResource: jsonFile, ofType: "json") else {
            fatalError("\(jsonFile).json not found")
        }
        
        guard  let data = try? Data(contentsOf: URL(fileURLWithPath: json), options: []) else {
            fatalError("Unable to convert \(jsonFile).json to Data")
        }
        return data
    }
}
