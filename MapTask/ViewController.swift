//
//  ViewController.swift
//  MapTask
//
//  Created by Елена Дранкина on 03.11.2021.
//

import UIKit
import MapKit
import CoreLocation
/*
  Так как приложение без сториборда. перед работой настраиваем сцинДелегейт и пилист.
*/

class ViewController: UIViewController {
/* Объявляем переменные
     pins сюда запишем результат парсинга джесона и будем работать с ним.
     annotationsForRoute аннотации для одного маршрута запишем в этот массив
     allAnnotation сюда соберем все маршрутные аннотации
     routeDistance переменная для подсчета длинны маршрута
*/
    var pins: [Feature]?
    var annotationsForRoute: [MKPointAnnotation] = []
    var allAnnotations: [[MKPointAnnotation]] = []
    var routeDistance = 0.0
/*
     Создаем переменные для вью и определяем для них параметры отображения.
     Кнопки "посчитать маршрут", "сбросить все", а так же вью длины маршрута прячем? пока не распарсим джесон и не завершим работу с ним.
*/
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        return mapView
    }()
    
    let loadTrack: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "loadTrack"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let routeButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "routeButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let resetButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "resetButton"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        return button
    }()
    
    let routeDistanceView: UILabel = {
       let textView = UILabel()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.text = ""
        textView.isHidden = true
        textView.textColor = .red
        return textView
    }()
    /*
      Переопределяем вьюдидлоад. Вызываем из хелпера функцию настройки констрентов и определяем селекторы для кнопок,
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self

        setConstrains()
        loadTrack.addTarget(self, action:#selector(loadTrackButtonTapped), for: .touchUpInside)
        routeButton.addTarget(self, action:#selector(routeButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action:#selector(resetButtonTapped), for: .touchUpInside)
    }
    /*
       Прописываем работу кнопки "Загрузить маршрут". Работа с аннотациями подгружается из АннотейшнВьюКонтроллера.
     Парсинг джесона осуществляет нетворкСервис.
     В замыкании функции меняем видимость элементов, когда массив маршрутов загружен.
     Для отображения пинов с аннотациями используем адаптер координат и показываем аннотации. По завершении работы вызываем алерт,
     сообщающий пользователю о завершении загрузки.
    */
    @objc func loadTrackButtonTapped() {
        loadTrack.isHidden = true
        NetworkService.shared.fetchData(from: PinsUrl.pinApi.rawValue) { [self](data) in
            pins = data.features
            alertWithMessage(title: "Готово!", message: "Координаты маршрута загружены")
            loadTrack.isHidden = false
            coordinateAdapter()
            showAnnotations()
            resetButton.isHidden = false
            routeButton.isHidden = false
        }
    }
    /*
      Прорисовываем маршрут между пинами и считаем его длину. От числа элементов массива с аннотациями отнимаем двойку, так как при переборе начинаем с нулевого индекса (нужно отнять единицу так как каунт у нас начинается с 1 а не с 0. Еще единицу отнимаем, так как функция считает внутри индекс + 1 (следующий пин)
    */
    @objc func routeButtonTapped() {
        
        for annotations in allAnnotations {
            for index in 0...annotations.count - 2 {
                createRouteOnMap(annotations[index].coordinate, annotations[index + 1].coordinate) { [self](routeDistance) in
                    routeDistanceView.text = "\(routeDistance) метров"
                }
            }
            mapView.showAnnotations(annotations, animated: true)
        }
        routeDistanceView.isHidden = false
    }
    /*
         Удаляем аннотации и оверлеи с карты. Прячем кнопки.
    */
    @objc func resetButtonTapped() {
        clearAnnotations()
        resetButton.isHidden = true
        routeButton.isHidden = true
        routeDistanceView.isHidden = true
        mapView.removeOverlays(mapView.overlays)
    }
}

extension ViewController {
    /*
    С помощью фреймворка КорЛокэйшн выстраиваем маршрут от соседних пинов, для этого берем все маршруты и определяем самый короткий. В замыкании длинну маршрута между соседними пинами передаем в переменную, подсчитывающую длину маршрута.
    */
    private func createRouteOnMap(_ start: CLLocationCoordinate2D, _ destination: CLLocationCoordinate2D, with complition: @escaping ((Double) -> Void)) {
    
    let startLocation = MKPlacemark(coordinate: start)
    let finishLocation = MKPlacemark(coordinate: destination)
    
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startLocation)
        request.destination = MKMapItem(placemark:finishLocation)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        let direction = MKDirections(request: request)
        direction.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.alert(title: "Маршрут не доступен")
                return
            }
            
            var minRoute = response.routes[0]
            for route in response.routes {
                minRoute = (route.distance < minRoute.distance) ? route : minRoute
            }
            self.routeDistance += minRoute.distance
            DispatchQueue.main.async {
                complition(self.routeDistance)
            }
            self.mapView.addOverlay(minRoute.polyline)
        }
    }
}

extension ViewController: MKMapViewDelegate {
    /*
      Отрисовываем маршрут на карте с помощью МапКит оверлей.
    */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .red
        return renderer
    }
}
