//
//  FavoritesTableViewController.swift
//  ClimateControl
//
//  Created by Brando Flores on 11/27/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import Firebase

protocol FavoritesTableViewControllerDelegate {
    func sendBackLocation(selected location: Location)
}

class FavoritesTableViewController: UITableViewController {
    
    //MARK: Properties
    var locationsList = [Location]()
    let ref = Database.database().reference()
    var locationRef: DatabaseReference?
    var selectedLocation:Location = Location(cityName: "", zipcode: "")
    var delegate: FavoritesTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        var imageView = UIImageView(image: UIImage(named: "dark_background.png"))
        imageView.contentMode = .scaleAspectFit
        self.tableView.backgroundView = imageView
        tableView.tableFooterView = UIView()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        //cell.layer.backgroundColor = UIColor.clear.cgColor
        //loadLocationsFromDatabase {
          //  print(self.locationsList)
        //}
        //locationsList.append(Location(cityName: "test", zipcode: "test"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
      super.viewWillAppear(animated)

      // Add a background view to the table view
      let backgroundImage = UIImage(named: "dark_background.png")
      let imageView = UIImageView(image: backgroundImage)
      self.tableView.backgroundView = imageView
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteTableCell", for: indexPath) as? FavoriteTableViewCell else {
            fatalError("The dequeued cell is not an instance of FavoriteTableViewCell")
        }
        
        let location = locationsList[indexPath.row]
        cell.cityNameLabel.text = location.cityName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLocation = locationsList[indexPath.row]
        self.delegate?.sendBackLocation(selected: selectedLocation)
        print(selectedLocation)
        /*if let viewController = storyboard?.instantiateViewController(identifier: "WeatherViewController") as? WeatherViewController {
            viewController.selectedLocation = selectedLocation
            navigationController?.pushViewController(viewController, animated: true)
        }*/
        self.navigationController?.popViewController(animated: true)
        
    }
    
    /*func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
            let selected = locationsList[indexPath.row]
            delegate?.didSelectTableViewCell(selected: selected)
    
    }*/
    
    /*override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! WeatherViewController
        vc.selectedLocation = selectedLocation
        vc.viewDidLoad()
    }*/
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*func loadLocationsFromDatabase(_ completion: (() -> Void)?) {
        locationRef = ref.child("Users").child("xxperencexx")
        
        // Get each key-value pair in the database
        locationRef!.child("Locations").observeSingleEvent(of: .value, with: { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                //print(child.key)
                //print(child.value)
                var loc = Location(cityName: child.key, zipcode: child.value as! String)
                self.locationsList.append(loc)
            }
            completion?()
        })
    }*/
    

}
