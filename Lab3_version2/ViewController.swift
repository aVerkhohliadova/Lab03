//
//  ViewController.swift
//  Lab3_version2
//
//  Created by Алла Верхоглядова on 14.03.2023.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var weatherConditionImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureMetricssegmentControl: UISegmentedControl!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var isMetric = true
    
    let codeToSymbolColor: [Int: (symbol: String, colors: [UIColor])] = [
        //1: ("", [.red, .yellow]), // Main picture
        1000: ("sun.max", [.systemOrange, .systemYellow]), // Sunny
        1003: ("cloud.sun.fill", [.systemCyan, .systemOrange]), // Partly cloudy
        1006: ("cloud.fill", [.systemCyan, .systemOrange]), // Cloudy
        1009: ("cloud.fill", [.systemCyan, .systemOrange]), // Overcast
        1030: ("cloud.fog.fill", [.systemCyan, .systemBlue]), // Mist
        1063: ("cloud.rain.fill", [.systemCyan, .systemBlue]), // Patchy rain possible
        1066: ("cloud.snow.fill", [.systemCyan, .systemBlue]), // Patchy snow possible
        1069: ("cloud.sleet.fill", [.systemCyan, .systemBlue]), // Patchy sleet possible
        1072: ("cloud.sleet.fill", [.systemCyan, .systemBlue]), // Patchy freezing drizzle possible
        1087: ("cloud.bolt.fill", [.systemCyan, .systemYellow]), // Thundery outbreaks possible
        1114: ("wind.snow", [.systemCyan, .systemBlue]), // Blowing snow
        1117: ("wind.snow", [.systemCyan, .systemBlue]), // Blizzard
        1135: ("cloud.fog.fill", [.systemCyan, .systemBlue]), // Fog
        1147: ("cloud.fog.fill", [.systemCyan, .systemBlue]), // Freezing fog
        1150: ("cloud.drizzle", [.systemCyan, .systemBlue]), // Patchy light drizzle
        1153: ("cloud.drizzle.fill", [.systemCyan, .systemBlue]), // Light drizzle
        1168: ("cloud.sleet.fill", [.systemCyan, .systemBlue]), // Freezing drizzle
        1171: ("cloud.sleet.fill", [.systemCyan, .systemBlue]), // Heavy freezing drizzle
        1180: ("cloud.drizzle", [.systemCyan, .systemBlue]), // Patchy light rain
        1183: ("cloud.drizzle", [.systemCyan, .systemBlue]), // Light rain
        1186: ("cloud.rain.fill", [.systemCyan, .systemBlue]), // Moderate rain at times
        1189: ("cloud.rain.fill", [.systemCyan, .systemBlue]), // Moderate rain
        1192: ("cloud.heavyrain.fill", [.systemCyan, .systemBlue]), // Heavy rain at times
        1195: ("cloud.heavyrain.fill", [.systemCyan, .systemBlue]), // Heavy rain
        1198: ("cloud.sleet", [.systemCyan, .systemBlue]), // Light freezing rain
        1201: ("cloud.sleet.fill", [.systemCyan, .systemBlue]), // Moderate or heavy freezing rain
        1204: ("cloud.sleet", [.systemCyan, .systemBlue]), // Light sleet
        1207: ("cloud.sleet.fill", [.systemCyan, .systemBlue]), // Moderate or heavy sleet
        1210: ("cloud.snow", [.systemCyan, .systemBlue]), // Patchy light snow
        1213: ("cloud.snow", [.systemCyan, .systemBlue]), // Light snow
        1216: ("cloud.snow.fill", [.systemCyan, .systemBlue]), // Patchy moderate snow
        1219: ("cloud.snow.fill", [.systemCyan, .systemBlue]), // Moderate snow
        1222: ("cloud.snow.fill", [.systemCyan, .systemBlue]), // Patchy heavy snow
        1225: ("cloud.snow.fill", [.systemCyan, .systemBlue]), // Heavy snow
        1237: ("aqi.low", [.systemCyan, .systemBlue]), // Ice pellets
        1240: ("cloud.drizzle", [.systemCyan, .systemBlue]), // Light rain shower
        1243: ("cloud.rain.fill", [.systemCyan, .systemBlue]), // Moderate or heavy rain shower
        1246: ("cloud.rain.fill", [.systemCyan, .systemBlue]), // Torrential rain shower
        1249: ("cloud.sleet", [.systemCyan, .systemBlue]), // Light sleet showers
        1252: ("cloud.sleet.fill", [.systemCyan, .systemBlue]), // Moderate or heavy sleet showers
        1255: ("cloud.snow", [.systemCyan, .systemBlue]), // Light snow showers
        1258: ("cloud.snow.fill", [.systemCyan, .systemBlue]), // Moderate or heavy snow showers
        1261: ("aqi.low", [.systemCyan, .systemBlue]), // Light showers of ice pellets
        1264: ("aqi.medium", [.systemCyan, .systemBlue]), // Moderate or heavy showers of ice pellets
        1273: ("cloud.bolt.rain", [.systemCyan, .systemBlue]), // Patchy light rain with thunder
        1276: ("cloud.bolt.rain.fill", [.systemCyan, .systemBlue]), // Moderate or heavy rain with thunder
        1279: ("cloud.bolt.", [.systemCyan, .systemBlue]), // Patchy light snow with thunder
        1282: ("cloud.bolt.fill", [.systemCyan, .systemBlue]) // Moderate or heavy snow with thunder
    ]
    
    private var weather: Weather?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //displaySampleImageForDemo()
        searchTextField.delegate = self
        
        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
    }

    @IBAction func temperatureMetricsValueChanged(_ sender: UISegmentedControl) {
        isMetric = sender.selectedSegmentIndex == 0
        updateTemperatureLabel()
    }
    
    func updateTemperatureLabel(){
        guard let weather = weather else { return }
        let temperature = isMetric ? weather.temp_c : weather.temp_f
        let unit = isMetric ? "ºC" : "ºF"
        temperatureLabel.text = "\(temperature) \(unit)"
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        loadWeather(search: textField.text, latitude: 0.0, longtitude: 0.0)
        return true
    }
    
    private func displaySampleImageForDemo(code: Int){
        guard let (_, _) = codeToSymbolColor[code] else {
            print("Invalid code: \(code)")
            return
        }
        
        let config  = UIImage.SymbolConfiguration(paletteColors: codeToSymbolColor[code]?.colors ?? [.systemCyan, .systemBlue])
        weatherConditionImage.preferredSymbolConfiguration = config
        weatherConditionImage.image = UIImage(systemName: codeToSymbolColor[code]?.symbol ?? "")
    }

    @IBAction func onLocationTapped(_ sender: UIButton) {
        print("Button Location")
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .authorizedWhenInUse:
                print("User has granted permission to use location services")
//                locationManager.startUpdatingLocation()
            case .denied:
                print("User has denied permission to use location services")
                break
            default:
                print("The user has not yet made a choice regarding location services")
                break
            }
        }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        print(latitude)
        print(longitude)
        loadWeather(search: nil, latitude: latitude, longtitude: longitude)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error::: \(error.localizedDescription)")
    }
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: searchTextField.text, latitude: 0.0, longtitude: 0.0)
    }
    
    private func loadWeather(search: String?, latitude: Double, longtitude: Double){
        //Step 1: Getting URL:
        guard let url = getURL(query: search ?? "", latitude: latitude, longitude: longtitude) else {
            print("Could not get URL")
            return
        }
        
        //Step 2: Create URLSession
        let session = URLSession.shared
        
        //Step 3: Create task for the session
        let dataTask = session.dataTask(with: url) { [self] data, response, error in
            print("Network call comlete")
            
            guard error == nil else {
                print("Recieved error")
                return
            }
            
            guard let data = data else {
                print("No data found")
                return
            }
            
            if let weatherResponse = parseJSON(data: data){
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                print(weatherResponse.current.condition.text)
                
                DispatchQueue.main.async { [self] in
                    locationLabel.text = weatherResponse.location.name
                    weather = weatherResponse.current
                    updateTemperatureLabel()
                    weatherConditionLabel.text = weatherResponse.current.condition.text
                    displaySampleImageForDemo(code: weatherResponse.current.condition.code)
                }
            }
        }
        
        //Step 4: Start the task
        dataTask.resume()
        
    }
    
    private func getURL(query: String, latitude: Double, longitude: Double) -> URL? {
        let baseURL = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "c157243c17f94c8495673213231303"
//        let query = "q=Toronto"
        let aqi = "aqi=no"
        
        var url: String
        
        if query != "" {
            url = "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(String(describing: query))&\(aqi)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        } else {
            url = "\(baseURL)\(currentEndpoint)?key=\(apiKey)&q=\(latitude),\(longitude)&\(aqi)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
        
        print(url)
        return URL(string: url)
    }
    
    private func parseJSON(data: Data) -> WeatherResponse? {
        // Decode the data
        let decoder = JSONDecoder()
        var weather: WeatherResponse?
        
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
        } catch {
            print("Error decoding: \(error.localizedDescription)")
        }
        return weather
    }
    
}

struct WeatherResponse: Decodable {
    let location: Location
    let current: Weather
}

struct Location: Decodable {
    let name: String
}

struct Weather: Decodable {
    let temp_c: Float
    let temp_f: Float
    let condition: WeatherCondition
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}


