//
//  Pin.swift
//  MapTask
//
//  Created by Елена Дранкина on 03.11.2021.
//
import MapKit
/*
  Модель для парсинга джесона
*/

struct FeatureCollection: Decodable {
    let features: [Feature]?
}

struct Feature: Decodable {
    let geometry: Geometry?
}

struct Geometry: Decodable {
    let coordinates: [[[[CLLocationDegrees]]]]?
}


enum PinsUrl: String {
    case pinApi = "https://waadsu.com/api/russia.geo.json"
}
