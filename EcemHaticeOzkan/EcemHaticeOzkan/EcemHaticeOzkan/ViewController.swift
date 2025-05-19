import UIKit

struct Currency {
    let code: String
    let name: String
    let forexBuying: Double
    let forexSelling: Double
}

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var sourceCurrencyPicker: UIPickerView!
    @IBOutlet weak var targetCurrencyPicker: UIPickerView!
    @IBOutlet weak var rateTypeSegment: UISegmentedControl!
    @IBOutlet weak var resultLabel: UILabel!

    var currencyList: [String] = []
    var selectedCurrency1 = "USD"
    var selectedCurrency2 = "TRY"
    var exchangeRates: [String: Currency] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        sourceCurrencyPicker.delegate = self
        sourceCurrencyPicker.dataSource = self
        targetCurrencyPicker.delegate = self
        targetCurrencyPicker.dataSource = self
        amountTextField.delegate = self

        fetchExchangeRates()
    }

    func fetchExchangeRates() {
        guard let url = URL(string: "https://www.tcmb.gov.tr/kurlar/today.xml") else { return }

        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            let parser = TCMBXMLParser()
            parser.parse(data: data) { currencies in
                for currency in currencies {
                    self.exchangeRates[currency.code] = currency
                    if !self.currencyList.contains(currency.code) {
                        self.currencyList.append(currency.code)
                    }
                }

                // TRY'yi manuel olarak ekle
                let tryCurrency = Currency(code: "TRY", name: "Türk Lirası", forexBuying: 1.0, forexSelling: 1.0)
                self.exchangeRates["TRY"] = tryCurrency
                if !self.currencyList.contains("TRY") {
                    self.currencyList.insert("TRY", at: 0)
                }

                DispatchQueue.main.async {
                    self.sourceCurrencyPicker.reloadAllComponents()
                    self.targetCurrencyPicker.reloadAllComponents()
                    self.sourceCurrencyPicker.selectRow(0, inComponent: 0, animated: false)
                    self.targetCurrencyPicker.selectRow(1, inComponent: 0, animated: false)
                    self.selectedCurrency1 = self.currencyList[0]
                    self.selectedCurrency2 = self.currencyList[1]
                }
            }
        }
        task.resume()
    }

    func calculateExchange() {
        guard
            let amountText = amountTextField.text,
            let amount = Double(amountText),
            let fromRate = exchangeRates[selectedCurrency1],
            let toRate = exchangeRates[selectedCurrency2]
        else {
            resultLabel.text = "Hatalı giriş"
            return
        }

        let rateTypeIndex = rateTypeSegment.selectedSegmentIndex
        let fromValue = rateTypeIndex == 0 ? fromRate.forexBuying : fromRate.forexSelling
        let toValue = rateTypeIndex == 0 ? toRate.forexBuying : toRate.forexSelling

        let result = amount * fromValue / toValue
        resultLabel.text = String(format: "%.2f %@ = %.2f %@", amount, selectedCurrency1, result, selectedCurrency2)
    }

    @IBAction func calculateButtonTapped(_ sender: UIButton) {
        calculateExchange()
    }

    @IBAction func swapCurrencies(_ sender: UIButton) {
        swap(&selectedCurrency1, &selectedCurrency2)
        let row1 = currencyList.firstIndex(of: selectedCurrency1) ?? 0
        let row2 = currencyList.firstIndex(of: selectedCurrency2) ?? 0
        sourceCurrencyPicker.selectRow(row1, inComponent: 0, animated: true)
        targetCurrencyPicker.selectRow(row2, inComponent: 0, animated: true)
        calculateExchange()
    }

    // MARK: - Picker View

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyList.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyList[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == sourceCurrencyPicker {
            selectedCurrency1 = currencyList[row]
        } else {
            selectedCurrency2 = currencyList[row]
        }
    }
}
