//
//  WeatherManager.swift
//  Clima
//
//  Created by Brando Flores on 9/28/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

var geocoder = CLGeocoder()
var countryCode: String = ""
let locationManager = CLLocationManager();
var lat: Double = 0.0
var lon: Double = 0.0
var weatherCopy: WeatherModel?


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
        self.delegate?.didUpdateWeather(self, weather: weatherCopy!)
    }
    
    // Fetch weather by latitude and longitude
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees ) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)";
        geocode(lat: latitude, lon: longitude)
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
                        weatherCopy = weather
                    }
                }
            }
            //4. start the task
            task.resume();
        }
    }
    
    func parseJSON(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder();
        
        /*
         * Get the latitude and longitude of the area and use it to find the
         * locations postal code with the geocode function
         */
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData);
            lat = decodedData.coord.lat
            lon = decodedData.coord.lon
            let id = decodedData.weather[0].id;
            let temp = decodedData.main.temp;
            let name = decodedData.name;
            let weather = WeatherModel(conditionID: id, cityName: name, temperature: temp, zipcode: countryCode, lat: lat, lon: lon);
            return weather;
        } catch {
            delegate?.didFailWithError(error: error);
            return nil;
        }
    }
    
    func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) -> String {

        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                //locationLabel.text = placemark.compactAddress
                countryCode = placemark.isoCountryCode ?? "No Postal Code Found"
            } else {
                countryCode = "No Postal Code Found"
            }
        }
        return countryCode
    }
    
    func geocode(lat: Double, lon: Double) {

        // Create location
        let location = CLLocation(latitude: lat, longitude: lon)
        
        // Geocode Location
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            // Process Response
            countryCode = self.processResponse(withPlacemarks: placemarks, error: error)
        }
    }
    
}
