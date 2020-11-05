//
//  AddItemViewController.swift
//  WeatherCombineDemo
//
//  Created by Denis Senichkin on 05.11.2020.
//

import UIKit
import Combine

class AddItemViewController: UIViewController {

    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet weak var btnAdd: UIButton!
    
    let newItem = PassthroughSubject<String, Never>()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tfInput.becomeFirstResponder()
    }
    
    @IBAction func btnAddClicked(_ sender: UIButton) {
        guard let text = tfInput.text, !text.isEmpty else { return }
        
        newItem.send(text)
        self.dismiss(animated: true, completion: nil)
    }
    
}
