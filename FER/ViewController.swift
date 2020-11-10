//
//  ViewController.swift
//  FER
//
//  Created by Dmitry Reshetnik on 09.11.2020.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var daysSwitcher: CustomSegmentedControl!
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private let dataManager: DataManager = DataManager(baseURL: ExchangeRatesAPI.BaseURL)
    var currencyRate: CurrencyRate?
    var rates: [String: Double] = [:]
    var now = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        currencyLabel.layer.cornerRadius = currencyLabel.frame.width / 2.0
        currencyLabel.clipsToBounds = true
        daysSwitcher.items = ["Yesterday", "Today"]
        daysSwitcher.selectedIndex = 1
        tableView.refreshControl = refreshControl
        tableView.dataSource = self
        tableView.rowHeight = 50.0
        refreshControl.addTarget(self, action: #selector(refreshCurrencyData(_:)), for: .valueChanged)
    }
    
    @objc private func refreshCurrencyData(_ sender: Any) {
        // Fetch Currency Data
        fetchCurrencyData()
    }
    
    private func fetchCurrencyData() {
        dataManager.getCurrencyRatesFor(base: "EUR", date: now, completion: { (currencyRate, error) in
            DispatchQueue.main.async {
                if let currencyRate = currencyRate {
                    self.currencyRate = currencyRate
                    self.rates = self.currencyRate!.rates
                }
                
                self.updateView()
                self.refreshControl.endRefreshing()
            }
        })
    }
    
    private func setupView() {
        tableView.isHidden = true
    }
    
    private func updateView() {
        let hasRates = rates.count > 0
        tableView.isHidden = !hasRates
        
        if hasRates {
            tableView.reloadData()
        }
    }


}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue Reusable Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyTableViewCell.ReuseIdentifier, for: indexPath) as! CurrencyTableViewCell
        
        let ticker = Array(rates.keys)[indexPath.row]
        let value = Array(rates.values)[indexPath.row]

        // Configure Cell
        cell.tickerLabel.text = ticker
        cell.valueLabel.text = String(value)

        return cell
    }

}

