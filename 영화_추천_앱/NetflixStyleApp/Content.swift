//
//  Content.swift
//  NetflixStyleApp
//
//  Created by 유혜빈 on 2022/02/11.
//

import UIKit

struct Content: Decodable{
    let sectionType: SectionType
    let sectionName: String
    let contentItem:[Item]
    
    enum SectionType: String, Decodable{
        case basic
        case main
        case large
        case rank
    }
}

struct Item: Decodable{
    let description: String
    let imageName: String
    
    var image: UIImage{
        return UIImage(named: imageName) ?? UIImage()
    }
}
