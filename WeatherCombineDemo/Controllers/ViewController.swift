//
//  ViewController.swift
//  WeatherCombineDemo
//
//  Created by Denis Senichkin on 04.11.2020.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private let refreshControl = UIRefreshControl()

    private let networking: NetworkProtocol = Network()
    private var subscriptions = Set<AnyCancellable>()
    private var cities: [CityModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initDataSource()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showHelp()
    }
    
    private func showHelp() {
        let text = "Click on row to refresh city\nPull to refresh to update all"
        AlertHelper.showAlert(text: text, from: self)
    }
}

//MARK:- DataSource
extension ViewController {

    private func initDataSource() {
        cities = [CityModel(name: "Kyiv"), CityModel(name: "Lviv"), CityModel(name: "Kropyvnytskyi")]
        
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }

    private func getWeather(for city: String) -> AnyPublisher<CityModel, Error> {
        let endpoint = Endpoint.weather(city: city)
        return networking.get(type: CityModel.self, url: endpoint.url)
    }
    
    @objc private func refreshData() {
        
        var publishers: [AnyPublisher<CityModel, Error>] = []
        for item in cities {
            let item = getWeather(for: item.name)
            publishers.append(item)
        }
        
        let total = Publishers.MergeMany(publishers)
        total.sink { [weak self] (completion) in
            self?.updateData()
        } receiveValue: { [weak self] (item) in
            self?.updateItemData(new: item)
        }.store(in: &subscriptions)
    }
    
    @objc private func updateData() {
        DispatchQueue.main.async { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.tableView.reloadData()
        }
    }
    
    private func addNewItem(new: String) {
        let item = CityModel(name: new)
        cities.append(item)
        tableView.reloadData()
        
        getWeatherForItem(name: new)
    }
    
    private func getWeatherForItem(name: String) {
        
        let publisher = getWeather(for: name)
        publisher.sink { [weak self] (completion) in
            self?.updateData()
        } receiveValue: { [weak self] (item) in
            self?.updateItemData(new: item)
        }.store(in: &subscriptions)
    }
    
    private func updateItemData(new: CityModel) {
        
        guard let index = cities.firstIndex(of: new) else { return }
        cities[index] = new
    }
}

//MARK:- Navigation
extension ViewController {
    
    @IBAction func btnAddClicked(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addItemViewController = storyBoard.instantiateViewController(withIdentifier: "AddItemViewController") as? AddItemViewController else { return }
        
        addItemViewController.newItem
            .handleEvents(receiveOutput: { [weak self] newItem in
                self?.addNewItem(new: newItem)
            })
            .sink { _ in }
            .store(in: &subscriptions)
        
        self.present(addItemViewController, animated: true, completion: nil)

    }
}

//MARK:- UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
        if indexPath.row < cities.count {
            let item = cities[indexPath.row]
            cell.textLabel?.text = item.name
            let detailed = (item.main?.temp != nil) ? "\(item.main?.temp ?? 0)°" : "n/a"
            cell.detailTextLabel?.text = detailed
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < cities.count {
            let item = cities[indexPath.row]
            getWeatherForItem(name: item.name)
        }
    }
    
}

