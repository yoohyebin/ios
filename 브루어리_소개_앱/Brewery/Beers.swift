//
//  Beers.swift
//  Brewery
//
//  Created by 유혜빈 on 2022/03/07.
//

import Foundation

struct Beer: Decodable{
    let id: Int?
    let name, tagline, description, imageUrl, brewersTips: String?
    let foodPairing: [String]?
    
    var tagLine: String{
        let tags = tagline?.components(separatedBy: ".")
        let hasTags = tags?.map{
            "#" + $0.replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: ".", with: "")
                .replacingOccurrences(of: ",", with: " #")
        }
        return hasTags?.joined(separator: " ") ?? ""
    }
    
    enum CodingKeys: String, CodingKey{
        case id, tagline, name, description
        case imageUrl = "image_url"
        case brewersTips = "brewers_tips"
        case foodPairing = "food_pairing"
    }
}
