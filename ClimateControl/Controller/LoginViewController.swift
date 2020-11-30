//
//  LoginViewController.swift
//  ClimateControl
//
//  Created by Brando Flores on 11/26/20.
//  Copyright © 2020 App Brewery. All rights reserved.
//

import UIKit
import GoogleSignIn
import CLTypingLabel

class LoginViewController: UIViewController, GIDSignInDelegate {
    var idToken: String?
    var email: String?
    @IBOutlet weak var titleLabel: CLTypingLabel!

    // Hides the navigation bar in the welcome screen.
    // We do this here an dfollow up for the other screens
    override func viewWillAppear(_ animated: Bool) {
        // Good practice to call super whenever override is called
        super.viewWillAppear(animated);
        navigationController?.isNavigationBarHidden = true;
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        super.navigationController?.isNavigationBarHidden = false;
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "🌤ClimateControl";

        GIDSignIn.sharedInstance()?.presentingViewController = self

        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        GIDSignIn.sharedInstance().delegate = self
        
        // Customize sign in button
        //signInButton.style = GIDSignInButtonStyle.iconOnly
        // ^ Too small, will create custom
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // Check if user sucessfully signed in
        if(GIDSignIn.sharedInstance()?.currentUser != nil)
        {
            email = GIDSignIn.sharedInstance()?.currentUser.profile.email
            idToken = user.authentication.idToken
            performSegue(withIdentifier: "toWeatherView", sender: nil)
        }
        else {
            print("User was not able to sign in.")
        }
        
    }
    
    // use the signOut method of the GIDSignIn object to sign out your user on the current device
    @IBAction func didTapSignOut(_ sender: AnyObject) {
      GIDSignIn.sharedInstance().signOut()
    }
    
    
    @IBAction func signInButtonPressed(_ sender: UIButton? ) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    /*
     * Send the username to the next view controller to update the correct
     * database
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toWeatherView") {
            let vc = segue.destination as! WeatherViewController
            vc.user = idToken
            vc.user = email
        }
    }

}
