import Foundation
import CoreLocation


protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    
    func didFailWithError(_ error: Error)
}


struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?units=metric&appid=0c35269e1dd110a080b86959949fe9ae"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let url = "\(weatherURL)&q=\(cityName)"
        
        performRequest(with: url)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let url = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        
        performRequest(with: url)
    }
    
    func performRequest(with urlString: String) {
        // 1. Create URL
        if let url = URL(string: urlString) {
            // 2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            // 3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = self.parseJOSN(safeData) {
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            // 4. Start the task
            task.resume()
        }
        
    }
    
    func parseJOSN(_ weatherData: Data)-> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            
            let weather = WeatherModel(temperature: temp, cityName: name, conditionId: id)
            
            return weather
        } catch {
            delegate?.didFailWithError(error)
            return nil
        }
    }
}
