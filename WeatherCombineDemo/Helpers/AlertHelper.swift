//
//  AlertHelper.swift
//  WeatherCombineDemo
//
//  Created by Denis Senichkin on 05.11.2020.
//

import Foundation
import UIKit

class AlertHelper {
    
    class func showAlert(text: String, from: UIViewController) {
        
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        from.present(alert, animated: true, completion: nil)
    }
}
