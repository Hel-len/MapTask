//
//  AnnotationsViewController.swift
//  MapTask
//
//  Created by Елена Дранкина on 04.11.2021.
//

import Foundation
import MapKit
/*
  Работаем с аннотациями
*/
extension ViewController {
    /*
      Пробегаемся по массиву, полученному после парсинга джесон файла.
    */
    func coordinateAdapter() -> [[CLLocationCoordinate2D]] {
        var route: [CLLocationCoordinate2D] = []
        var routes: [[CLLocationCoordinate2D]] = []
        var numberOfPin = 1
        var numberOfRoute = 1
        
        for geometry in pins! {
            let tracks = geometry.geometry?.coordinates
            for track in tracks! {
                for coordinates in track {
                    for coordinate in coordinates {
                        /*
                          Так как исходный джесон файл содержит 213 маршрутов, большая часть из которых расположена
                         на территории, построение маршрута для которой недоступно, а так же из-за лимита обращений к серверу
                         ограничиваем пины координатами.
                         Я приняла решение сделать именно так в этом учебном задании.
                         В реальном приложении можно вызывать алерт-контроллер, сообщающий о невозможности
                         построения некоторых маршрутов, а так же вызывать запрос на построение
                         определенного маршрута. Для обхода проблемы с запросами на сервер в таком случае
                         необходимо выставлять делей между запросами.
                         Далее меняем местами координаты, так как карта работает с координатами
                         формата (широта, долгота) а геоДжесон - (долгота, широта)
                         Добавляем пин в массив маршрута.
                        */
                        if Double(coordinate[1]) > 54.0 && Double(coordinate[1]) < 55.0 {
                            if Double(coordinate[0]) > 31.0 && Double(coordinate[0]) < 32.0 {
                                let routePin = CLLocationCoordinate2D(latitude: coordinate[1], longitude: coordinate[0])
                                route.append(routePin)
                                addAnnotation(routePin, numberOfPin, numberOfRoute)
                                numberOfPin += 1
                            }
                        }
                    }
                    /*
                      Отсекаем пустые и короткие маршруты. Добавляем маршрут в массив со всеми маршрутами.
                     Обнуляем счетчик пинов на маршруте, к счетчику маршрутов прибавляем единицу.
                     Этот функционал в данном решении излишний, так как по итогу у нас получился только один маршрут.
                    */
                    if route.count > 5 {
                        routes.append(route)
                        addAnnotations()
                        numberOfPin = 1
                        numberOfRoute += 1
                    }
                }
            }
        }
        return routes
    }
    /*
         Создаем аннотации к пинам и вносим их в массив аанотаций маршрута
    */
    private func addAnnotation(_ pin: CLLocationCoordinate2D, _ pinNumber: Int, _ routeNumber: Int) {
        
        let annotation = MKPointAnnotation()
        annotation.title = "Точка \(pinNumber) маршрута \(routeNumber)"
        annotation.coordinate = pin
        annotationsForRoute.append(annotation)
    }
    /*
      Если массив с аннотациями не пустой, добавляем его ко всем маршрутам.
     Обнуляем массив с аннотациями для одного маршрута
    */
    private func addAnnotations() {
        
        if annotationsForRoute.count > 3 {
            allAnnotations.append(annotationsForRoute)
        }
        annotationsForRoute = []
    }
    /*
      Отрисовываем аннотации на карте
    */
    func showAnnotations() {
        for annotations in allAnnotations {
            mapView.showAnnotations(annotations, animated: true)
        }
    }
    /*
      Удаляем все аннотации с карты и обнуляем массив
    */
    func clearAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        allAnnotations = []
    }
}
