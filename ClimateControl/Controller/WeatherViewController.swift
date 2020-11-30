//
//  ViewController.swift
//  Clima
//
//

/*
 Log to fix:
 * Display error when no location found
 */

import UIKit
import CoreLocation
import Firebase
import GoogleSignIn

class WeatherViewController: UIViewController, FavoritesTableViewControllerDelegate {
    
    func sendBackLocation(selected location: Location) {
        selectedLocation = location
        weatherManager.fetchWeather(cityName: location.cityName!)
    }
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var zipcodeLabel: UILabel!
    
    var weatherManager = WeatherManager();
    let locationManager = CLLocationManager();
    let ref = Database.database().reference()
    var user: String?
    var locationRef: DatabaseReference?
    var weatherCopy: WeatherModel?
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=16c440cd417d067c3f006009652f7b14&units=imperial";
    var locationsList = [Location]()
    var selectedLocation:Location = Location(cityName: "", zipcode: "")
    
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
        locationRef = Database.database().reference()
        locationRef = ref.child("Users").child(username)
        locationRef?.child("Locations").observeSingleEvent(of: .value, with: { (snapshot) in
            
            if snapshot.hasChild(self.cityLabel.text! ){
                self.favoriteButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: UIControl.State.normal)
                
            }else{
                self.favoriteButton.setBackgroundImage(UIImage(systemName: "heart"), for: UIControl.State.normal)
            }
            
            
        })
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true);
    }
    
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        if (favoriteButton.currentBackgroundImage == UIImage(systemName: "heart")) {
            favoriteButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: UIControl.State.normal)
            let username = (user?.replacingOccurrences(of: "@gmail.com", with: ""))!
            locationRef = self.ref.child("Users").child(username)
            
            // Add a location to the database
            locationRef!.child("Locations").updateChildValues([cityLabel.text!:"85205"])
            
            
        }
        else {
            favoriteButton.setBackgroundImage(UIImage(systemName: "heart"), for: UIControl.State.normal)
            // remove child value
            locationRef!.child("Locations").child(weatherCopy?.cityName ?? "").removeValue()
        }
    }
    
    func loadLocationsFromDatabase(_ completion: (() -> Void)?) {
        locationsList.removeAll()
        let username = (user?.replacingOccurrences(of: "@gmail.com", with: ""))!
        locationRef = ref.child("Users").child(username)
        
        // Get each key-value pair in the database
        locationRef!.child("Locations").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let loc = Location(cityName: child.key, zipcode: child.value as? String)
                self.locationsList.append(loc)
            }
            completion?()
        })
    }
    @IBAction func favoritesButtonPressed(_ sender: UIBarButtonItem) {
        loadLocationsFromDatabase {
            self.performSegue(withIdentifier: "toFavoriteTableView", sender: nil)
        }
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIBarButtonItem) {
        GIDSignIn.sharedInstance().signOut()
        self.navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFavoriteTableView" {
            let vc = segue.destination as! FavoritesTableViewController
            vc.delegate = self
            vc.locationsList = self.locationsList
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

/*
 * Checks if a given string is and INT
 */
func isInt(string: String) -> Bool {
    return Int(string) != nil
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didFailWithError(error: Error) {
        print(error);
    }
    
    func didUpdateWeather( _ weatherManager: WeatherManager, weather: WeatherModel ) {
        let queue = DispatchQueue(label: "update")
        
        queue.async {
            countryCode = weather.zipcode
        }
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temp;
            self.conditionImageView.image = UIImage(systemName: weather.conditionName )
            self.cityLabel.text = weather.cityName;
            self.zipcodeLabel.text = countryCode
            self.weatherCopy = weather
            
            /*
             * Get the current user to manage database
             */
            let username = (self.user?.replacingOccurrences(of: "@gmail.com", with: ""))!
            self.locationRef = Database.database().reference()
            self.locationRef = self.ref.child("Users").child(username)
            self.locationRef?.child("Locations").observeSingleEvent(of: .value, with: { (snapshot) in
                
                // Automatically manage how the user percieves the favorites button.
                // Once a user selects/deselects a location, it will update the
                // heart image to reflect its status in the database
                if snapshot.hasChild(self.cityLabel.text! ){
                    self.favoriteButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: UIControl.State.normal)
                    
                }else{
                    self.favoriteButton.setBackgroundImage(UIImage(systemName: "heart"), for: UIControl.State.normal)
                }
                
                
            })
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

extension CLLocation {
    func geocode(completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(self, completionHandler: completion)
    }
}
