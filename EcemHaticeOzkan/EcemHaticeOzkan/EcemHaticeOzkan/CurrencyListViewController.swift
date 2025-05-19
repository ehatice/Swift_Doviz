import UIKit

class CurrencyListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var currencyList: [Currency] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // view.backgroundColor = .white
        
        tableView.delegate = self
        tableView.dataSource = self
        fetchExchangeRates()
    }
    
    func fetchExchangeRates() {
        guard let url = URL(string: "https://www.tcmb.gov.tr/kurlar/today.xml") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            let parser = TCMBXMLParser()
            parser.parse(data: data) { currencies in
                self.currencyList = currencies
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        task.resume()
    }
    
    // MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyCell", for: indexPath)
        let item = currencyList[indexPath.row]
        cell.textLabel?.text = "\(item.code) - \(item.name): \(item.forexBuying) / \(item.forexSelling)"
        return cell
    }
    
    @IBAction func goToCalculationPage(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let destinationVC = storyboard.instantiateViewController(withIdentifier: "CalculationVC") as? ViewController {
            self.navigationController?.pushViewController(destinationVC, animated: true)
        }
    }
    
}
