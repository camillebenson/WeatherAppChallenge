//
//  ViewController.swift
//  Rain or Shine
//
//  Created by Camille Benson on 5/25/15.
//  Copyright (c) 2015 Carleton College. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    // Personal account API Key
    let APIKey = "da19918271925889a9ce01df1846c811"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Default city: Minneapolis
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?q=Minneapolis&APPID=")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
    Retrieves weather data from api.openweathermap.org server, error checks
    and changes labels if necessary.
    
    :returns: void
    */
    func getWeatherData(url: String) {
        var urlString = String(url + APIKey)
        let session = NSURLSession.sharedSession()
        var weatherURL = NSURL(string: urlString)
        
        var task = session.dataTaskWithURL(weatherURL!){
            (data, response, error) -> Void in
            if error != nil {
                // Print error to screen...
                println(error.localizedDescription)
                println("printed error")
                dispatch_async(dispatch_get_main_queue()) {
                    self.descriptionLabel.text = String("Error: " + error.localizedDescription)
                    self.tempLabel.text = ""
                    self.cityLabel.text = ""
                    //self.cityTextField.text = "City"
                }
            } else {
                // Updates Labels immediately on main thread
                dispatch_async(dispatch_get_main_queue()) {
                    self.parseWeatherData(data)
                }
            }
        }
        task.resume()
    }
    
    /**
    Parse weather NSData input, parses for specific information
    to display on screen: City Name, Temperature(°F), Weather Icon, Weather Description.
    
    :param: weatherData NSData to be parsed for info
    :returns: void
    */
    func parseWeatherData(weatherData: NSData) {
        var jsonerror: NSError?
        if let json = NSJSONSerialization.JSONObjectWithData(weatherData, options: nil, error: &jsonerror) as? NSDictionary {
            // Parse for name of city
            if let name = json["name"] as? String {
                cityLabel.text = name
                println(name)
            }
            // Parse for temperature and convert
            if let main = json["main"] as? NSDictionary {
                if let temp = main["temp"] as? Double {
                    println(temp)
                    // Fahrenheit to Kelvin conversion
                    // Eqn: T(°F) = T(K) × 9/5 - 459.67
                    var convertedTemp = ((temp * (9.0/5.0)) - 459.67)
                    // Round up Fahrenheit calculation to Int
                    var roundedTemp = String(format: "%.0f",convertedTemp)
                    var finalTemp = String(roundedTemp + "°F")
                    println(finalTemp)
                    self.tempLabel.text = finalTemp
                }
            }
            // Parse for weather icon and description
            if let weather = json["weather"] as? NSArray {
                let set: AnyObject! = weather[0]
                // Icon
                if let icon: AnyObject! = set["icon"] {
                    println(set["icon"])
                    self.iconImageView.image = UIImage(named: icon! as! String)
                }
                // Description
                if let description: AnyObject! = set["description"] {
                    println(set["description"])
                    self.descriptionLabel.text = description as? String
                }
            }
        }
    }
}

