//
//  NetworkService.swift
//  MapTask
//
//  Created by Елена Дранкина on 03.11.2021.
//

import Foundation
import MapKit
/*
     Парсим джесон не как геоджесон (так как содержит много ненужной нам в работе информации). Проверяем урл, является ли ссылкой,
*/
class NetworkService {
    static let shared = NetworkService()
    private init () {}
    var collection = FeatureCollection(features: nil)
    
    func fetchData(from url: String?, with complition: @escaping (FeatureCollection) -> Void) {
        
        guard let stringURL = url else { return }
        guard let url = URL(string: stringURL) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print(error)
                return
            }
            guard let data = data else { return }
            
            do {
                let data = try JSONDecoder().decode(FeatureCollection.self, from: data)
                
                DispatchQueue.main.async {
                    complition(data)
                }
                
            } catch let error {
                print(error)
            }
        }.resume()
    }
}
