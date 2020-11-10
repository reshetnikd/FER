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
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var daysSwitcher: CustomSegmentedControl!
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    private let dataManager: DataManager = DataManager(baseURL: ExchangeRatesAPI.BaseURL)
    var rates: [String: Double] = [:]
    var yesterday: Date = Date(timeInterval: -86400 * 2, since: Date())
    var now: Date = Date()
    var chosenDate: Date = Date()
    var baseCurrency: String = "EUR"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        fetchCurrencyData()
    }
    
    @objc private func refreshCurrencyData(_ sender: Any) {
        // Fetch currency data
        fetchCurrencyData()
    }
    
    @objc private func changeDateAndRefreshCurrencyData(_ sender: Any) {
        // Fetch currency data with new date
        if daysSwitcher.selectedIndex == 1 {
            chosenDate = now
        } else {
            chosenDate = yesterday
        }
        
        fetchCurrencyData()
    }
    
    private func fetchCurrencyData() {
        dataManager.getCurrencyRatesFor(base: baseCurrency, date: chosenDate, completion: { (currencyRate, error) in
            DispatchQueue.main.async {
                if let currencyRate = currencyRate {
                    self.rates = currencyRate.rates
                }
                
                self.updateView()
                self.refreshControl.endRefreshing()
                self.activityIndicatorView.stopAnimating()
            }
        })
    }
    
    private func setupView() {
        setupTableView()
        setupMessageLabel()
        setupActivityIndicatorView()
        setupDaysSwitcher()
        setupRefreshControl()
        currencyLabel.layer.cornerRadius = currencyLabel.frame.width / 2.0
        currencyLabel.clipsToBounds = true
    }
    
    private func setupTableView() {
        tableView.isHidden = true
        tableView.refreshControl = refreshControl
        tableView.dataSource = self
        tableView.rowHeight = 50.0
    }
    
    private func setupMessageLabel() {
        messageLabel.isHidden = true
        messageLabel.textColor = UIColor.systemTeal
        messageLabel.backgroundColor = UIColor.white
        messageLabel.layer.cornerRadius = messageLabel.frame.width / 8.0
        messageLabel.textAlignment = NSTextAlignment.center
        messageLabel.clipsToBounds = true
        messageLabel.text = "You're offline. Check your connection."
    }
    
    private func setupActivityIndicatorView() {
        activityIndicatorView.startAnimating()
    }
    
    private func setupDaysSwitcher() {
        daysSwitcher.items = ["Yesterday", "Today"]
        daysSwitcher.selectedIndex = 1
        daysSwitcher.addTarget(self, action: #selector(changeDateAndRefreshCurrencyData(_:)), for: UIControl.Event.valueChanged)
    }
    
    private func setupRefreshControl() {
        refreshControl.tintColor = UIColor.systemTeal
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Currency Rates ...")
        refreshControl.addTarget(self, action: #selector(refreshCurrencyData(_:)), for: UIControl.Event.valueChanged)
    }
    
    private func updateView() {
        let hasRates = rates.count > 0
        tableView.isHidden = !hasRates
        activityIndicatorView.isHidden = !hasRates
        messageLabel.isHidden = hasRates
        
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
        // Dequeue reusable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyTableViewCell.ReuseIdentifier, for: indexPath) as! CurrencyTableViewCell
        
        // Configure data for cell
        let sortedKeys = rates.keys.sorted { (lhs, rhs) -> Bool in
            lhs.localizedStandardCompare(rhs) == ComparisonResult.orderedAscending
        }
        
        let ticker = sortedKeys[indexPath.row]
        let value = rates[sortedKeys[indexPath.row]]!

        // Configure cell
        cell.tickerLabel.text = ticker
        cell.valueLabel.text = String(value)

        return cell
    }

}

