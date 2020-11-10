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
    var currencyRate: CurrencyRate?
    var rates: [String: Double] = [:]
    
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
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        loadData()
    }
    
    @objc private func refreshData(_ sender: Any) {
        // Fetch Data
        print("Fetch data")
        loadData()
    }
    
    func loadData() {
        guard let url = URL(string: "https://api.exchangeratesapi.io/latest") else {
            print("Invalid URL")
            return
        }
        
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(CurrencyRate.self, from: data) {
                    DispatchQueue.main.async {
                        self.currencyRate = decodedResponse
                        self.rates = self.currencyRate!.rates
                        self.tableView.reloadData()
                    }
                    
                    return
                }
            }
            print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
        }).resume()
    }


}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue Reusable Cell
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyTableViewCell.ReuseIdentifier, for: indexPath) as! CurrencyTableViewCell

        // Configure Cell
        cell.tickerLabel.text = Array(rates.keys)[indexPath.row]
        cell.valueLabel.text = String(Array(rates.values)[indexPath.row])

        return cell
    }

}

