//
//  ViewController.swift
//  Clima
//
//

/*
 Log to fix:
 * Display error when no location found
 * Login design and constraints
 * Remove back button on weatherviewcontroller
 */

import UIKit
import CoreLocation
import Firebase

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var weatherManager = WeatherManager();
    let locationManager = CLLocationManager();
    let ref = Database.database().reference()
    var user: String?
    var locationRef: DatabaseReference?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self;
        locationManager.requestWhenInUseAuthorization();
        locationManager.requestLocation();
        // startUpdatingLocation() constantly reports back like for navigation
        
        //Remove back button
        self.navigationItem.setHidesBackButton(true, animated: false)
        
        //Make navigation bar transluscent
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
        weatherManager.delegate = self;
        searchTextField.delegate = self;
        
        // Define and create a reference to the database
        //var ref: DatabaseReference!
        //ref = Database.database().reference()
        
        let username = (user?.replacingOccurrences(of: "@gmail.com", with: ""))!
        locationRef = self.ref.child("Users").child(username)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true);
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        if (favoriteButton.currentBackgroundImage == UIImage(systemName: "heart")) {
            favoriteButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: UIControl.State.normal)
            
            // Add child value
            locationRef!.child("Locations").updateChildValues(["Scottsdale":"85257"])
            locationRef!.child("Locations").updateChildValues(["Tempe":"85281"])
            locationRef!.child("Locations").updateChildValues(["Chandler":"85255"])
            
            
        }
        else {
            favoriteButton.setBackgroundImage(UIImage(systemName: "heart"), for: UIControl.State.normal)
            // remove child value
            locationRef!.child("Locations").child("Chandler").removeValue()
        }
    }
    
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true);
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true);
        return true;
    }
    
    /*
     This function is usefule for validation, like checking if the text field is empty.
     */
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if textField.text!.isEmpty {
            textField.placeholder = "Enter a city.";
            return false;
        }
        else {
            return true;
        }
    }
    
    /*
     Delegate is called when search is pressed. You could just clear the text upon pusing a button but this allows you to do it regardless of if you press search or go on the keyboard.
     */
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //Use searchField.text to get the weather for that city
        //User may have entered either a city name or a zipcode
        if isInt(string: searchTextField.text!) {
            let zipcode = Int(searchTextField.text!)!
            weatherManager.fetchWeather(zipcode: zipcode)
        }
        else {
            if let city = searchTextField.text {
                weatherManager.fetchWeather(cityName: city);
            }
        }
        searchTextField.text = "";
    }
}

func isInt(string: String) -> Bool {
    return Int(string) != nil
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didFailWithError(error: Error) {
        print(error);
    }
    
    func didUpdateWeather( _ weatherManager: WeatherManager, weather: WeatherModel ) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temp;
            self.conditionImageView.image = UIImage(systemName: weather.conditionName )
            self.cityLabel.text = weather.cityName;
        }
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation();
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation();
            let lat = location.coordinate.latitude;
            let lon = location.coordinate.longitude;
            weatherManager.fetchWeather(latitude: lat, longitude: lon );
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error);
    }
}

