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
    @IBOutlet weak var zipcodeLabel: UILabel!
    
    var weatherManager = WeatherManager();
    let locationManager = CLLocationManager();
    let ref = Database.database().reference()
    var user: String?
    var locationRef: DatabaseReference?
    var weatherCopy: WeatherModel?
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=16c440cd417d067c3f006009652f7b14&units=imperial";
    var locationsList = [Location]()
    
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
        
        //let username = (user?.replacingOccurrences(of: "@gmail.com", with: ""))!
        //locationRef = self.ref.child("Users").child(username)
        locationRef = Database.database().reference()
        locationRef = ref.child("Users").child("xxperencexx")
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
            locationRef = self.ref.child("Users").child("xxperencexx")

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
        locationRef = ref.child("Users").child("xxperencexx")
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "toFavoriteTableView" {
                let vc = segue.destination as! FavoritesTableViewController
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
                /*let urlString = "\(weatherURL)&q=\(city)"
                //1. create a url
                if let url = URL(string: urlString) {
                    //2. create a url session
                    let session = URLSession(configuration: .default);
                    
                    //3. give the session a task
                    let task = session.dataTask(with: url) { [self] (data, response, error) in
                        if error != nil {
                            //self.delegate?.didFailWithError(error: error!)
                            return;
                        }
                        
                        if let safeData = data {
                               weatherCopy = parseJSON(weatherData: safeData)
                                //self.delegate?.didUpdateWeather(self, weather: weather);
                                //weatherCopy = weather
                                print("first")
                            print(weatherCopy?.zipcode)
                            DispatchQueue.main.async {
                                print("second")
                                print(weatherCopy?.zipcode)
                            }
                        }
                    }
                    //4. start the task
                    task.resume();
                }*/
            }
        }
        //geocode(lat: weatherCopy!.lon, lon: weatherCopy!.lon)
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
        let queue = DispatchQueue(label: "update")

        queue.async {
            countryCode = weather.zipcode
            print(countryCode)
        }
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temp;
            self.conditionImageView.image = UIImage(systemName: weather.conditionName )
            self.cityLabel.text = weather.cityName;
            self.zipcodeLabel.text = countryCode
            self.weatherCopy = weather
            print(self.weatherCopy?.cityName as Any)
            print(countryCode)
            print("fourth")
            
            
            self.locationRef = Database.database().reference()
            self.locationRef = self.ref.child("Users").child("xxperencexx")
            self.locationRef?.child("Locations").observeSingleEvent(of: .value, with: { (snapshot) in

                if snapshot.hasChild(self.cityLabel.text! ){
                    self.favoriteButton.setBackgroundImage(UIImage(systemName: "heart.fill"), for: UIControl.State.normal)

                    }else{
                        self.favoriteButton.setBackgroundImage(UIImage(systemName: "heart"), for: UIControl.State.normal)
                    }


                })
        }

        print("fifth")
    }
    
    func updateWeather(zip: String) {
        self.zipcodeLabel.text = zip
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
