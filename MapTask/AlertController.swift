//
//  AlertController.swift
//  MapTask
//
//  Created by Елена Дранкина on 03.11.2021.
//

import UIKit

extension UIViewController {
    
    func alertWithMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertOk = UIAlertAction(title: "Ok", style: .default)
        
        alertController.addAction(alertOk)
        present(alertController, animated: true, completion: nil)
    }
    
}
