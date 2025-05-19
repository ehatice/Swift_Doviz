import Foundation

class TCMBXMLParser: NSObject, XMLParserDelegate {
    private var currencies: [Currency] = []
    private var currentElement = ""
    private var code = "", name = "", buying = "", selling = ""
    private var completion: (([Currency]) -> Void)?

    func parse(data: Data, completion: @escaping ([Currency]) -> Void) {
        self.completion = completion
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?,
                attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        if elementName == "Currency" {
            code = attributeDict["CurrencyCode"] ?? ""
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        switch currentElement {
        case "Isim": name += trimmed
        case "ForexBuying": buying += trimmed
        case "ForexSelling": selling += trimmed
        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String,
                namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "Currency" {
            if let b = Double(buying.replacingOccurrences(of: ",", with: ".")),
               let s = Double(selling.replacingOccurrences(of: ",", with: ".")) {
                let currency = Currency(code: code, name: name, forexBuying: b, forexSelling: s)
                currencies.append(currency)
            }
            code = ""; name = ""; buying = ""; selling = ""
        }
    }

    func parserDidEndDocument(_ parser: XMLParser) {
        completion?(currencies)
    }
}
