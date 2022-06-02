//
//  CreditCard.swift
//  CreditCardList
//
//  Created by 유혜빈 on 2021/12/09.
//

import Foundation

struct CreditCard: Codable{
    let id: Int
    let rank: Int
    let name: String
    let cardImageURL: String
    let promotionDetail: PromotionDetail
    let isSelected: Bool?
}

struct PromotionDetail: Codable{
    let companyName: String
    let amount: Int
    let period: String 
    let benefitDate: String
    let benefitDetail: String
    let benefitCondition: String
    let condition: String
}
