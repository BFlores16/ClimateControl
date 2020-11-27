//
//  WeatherManager.swift
//  Clima
//
//  Created by Brando Flores on 9/28/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather( _ weatherManager: WeatherManager, weather: WeatherModel );
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=16c440cd417d067c3f006009652f7b14&units=imperial";
    
    var delegate: WeatherManagerDelegate?;
    
    // Fetch weather by city name
    func fetchWeather( cityName: String ) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString);
    }
    
    // Fetch weather by latitude and longitude
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees ) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)";
        performRequest(with: urlString);
    }
    
    //api.openweathermap.org/data/2.5/weather?zip={zip code},{country code}&appid={API key}
    // Fetch Weather by zip code
    func fetchWeather( zipcode: Int ) {
        let urlString = "\(weatherURL)&zip=\(zipcode),us"
        performRequest(with: urlString);
    }
    
    func performRequest(with urlString: String) {
        //1. create a url
        if let url = URL(string: urlString) {
            //2. create a url session
            let session = URLSession(configuration: .default);
            
            //3. give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return;
                }
                
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather);
                    }
                }
            }
            //4. start the task
            task.resume();
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder();
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData);
            print("test")
            print(decodedData)
            let id = decodedData.weather[0].id;
            let temp = decodedData.main.temp;
            let name = decodedData.name;
            
            let weather = WeatherModel(conditionID: id, cityName: name, temperature: temp);
            return weather;
        } catch {
            delegate?.didFailWithError(error: error);
            return nil;
        }
    }
    
}
