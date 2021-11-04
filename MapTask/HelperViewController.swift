//
//  HelperViewController.swift
//  MapTask
//
//  Created by Елена Дранкина on 03.11.2021.
//

import UIKit

extension ViewController {
    /*
      Настраиваем констрейнты для вьюшек.
     Во избежании дублирования кода настройку констрейнтов для кнопок запаковываем в отдельную функцию, в которую
     передаем изменяющиеся параметры.
    */
    func setConstrains() {
        view.addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        ])
        
        setConstraintsForButtons(for: loadTrack, mapView.leadingAnchor)
        setConstraintsForButtons(for: routeButton, loadTrack.trailingAnchor)
        setConstraintsForButtons(for: resetButton, routeButton.trailingAnchor)
        setConstraintsForText()
    }
    
    func setConstraintsForButtons(for button: UIButton, _ leadingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor>) {
        mapView.addSubview(button)
        NSLayoutConstraint.activate([
        button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
        button.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20),
        button.heightAnchor.constraint(equalToConstant: 30),
        button.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setConstraintsForText() {
        mapView.addSubview(routeDistanceView)
        NSLayoutConstraint.activate([
            routeDistanceView.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50),
            routeDistanceView.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 30),
            routeDistanceView.heightAnchor.constraint(equalToConstant: 50),
            routeDistanceView.widthAnchor.constraint(equalToConstant: 150)
        ])
    }
}
