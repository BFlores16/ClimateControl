//
//  WeatherModel.swift
//  Clima
//
//  Created by Brando Flores on 10/7/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation

struct WeatherModel {
    let conditionID: Int;
    let cityName: String;
    let temperature: Double;
    
    // Known as a computed property
    var conditionName: String {
        var condition:String?
        
        switch conditionID {
        case 200...232:
            condition = "cloud.bolt"
        case 300...321:
            condition = "cloud.drizzle"
        case 500...531:
            condition = "cloud.rain"
        case 600...622:
            condition = "cloud.snow"
        case 701...781:
            condition = "cloud.fog"
        case 800:
            condition = "sun.max"
        case 801...804:
            condition = "cloud.bolt"
        default:
            condition = "cloud"
        }
        
        return condition!;
    }
    
    var temp: String {
        let t = String( format: "%.1f", temperature );
        
        return t;
    }
    
}
