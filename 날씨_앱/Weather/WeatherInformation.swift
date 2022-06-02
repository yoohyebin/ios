//
//  WeatherInformation.swift
//  Weather
//
//  Created by 유혜빈 on 2021/11/29.
//

import Foundation

struct WeatherInformation: Codable{ //자신을 변환하거나 외부 표현으로 변환 할 수 있는 타입
    let weather: [Wheather]
    let temp: Temp
    let name: String
    
    enum CodingKeys: String, CodingKey{
        case weather
        case temp = "main"
        case name
    }
}

struct Wheather: Codable{
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Temp: Codable{
    let temp: Double
    let feelslike: Double
    let mintemp: Double
    let maxtemp: Double
    
    enum CodingKeys: String, CodingKey{
        case temp
        case feelslike = "feels_like"
        case mintemp = "temp_min"
        case maxtemp = "temp_max"
    }
}
