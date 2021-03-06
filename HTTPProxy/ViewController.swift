import UIKit

class GithubFilter: QuickFilter {
    let name = "Github"
    var enabled = false
    
    func matchesRequest(_ request: URLRequest) -> Bool {
        return request.url?.absoluteString.range(of: "github") != nil
    }
}

class ViewController: UIViewController {
    
    @IBOutlet private var intervalLabel: UILabel!
    @IBOutlet private var darkModeSwitch: UISwitch!
    var timer: Timer?
    var interval: Float = 5.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        HTTPProxy.shared.enable()
        HTTPProxy.shared.delegate = self
        darkModeSwitch.isOn = darkModeEnabled()
        
        self.sendRequest(self)
        
        var filters: [QuickFilter] = []
        
        var requestFilter = RequestFilter()
        requestFilter.host = "jsonplaceholder.typicode.com"
        let filter = HTTPProxyFilter(name: "jsonplaceholder", requestFilter: requestFilter)
        filters.append(filter)

        requestFilter = RequestFilter()
        requestFilter.host = "postman-echo.com"
        let filter2 = HTTPProxyFilter(name: "Postman", requestFilter: requestFilter)
        filters.append(filter2)
        
        requestFilter = RequestFilter()
        requestFilter.httpMethod = "DELETE"
        let filter3 = HTTPProxyFilter(name: "DELETE", requestFilter: requestFilter)
        filters.append(filter3)
        
        requestFilter = RequestFilter()
        requestFilter.queryItems = [KeyValuePair("foo2", "bar2")]
        let filter4 = HTTPProxyFilter(name: "query", requestFilter: requestFilter)
        filters.append(filter4)

        requestFilter = RequestFilter()
        requestFilter.scheme = "https"
        let filter5 = HTTPProxyFilter(name: "https", requestFilter: requestFilter)
        filter5.enabled = true
        filters.append(filter5)
        
        filters.append(GithubFilter())
        
        HTTPProxy.shared.filters = filters
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showMonitor(self)
        }
    }
    
    @IBAction func showMonitor(_ sender: Any) {
        HTTPProxy.shared.presentViewController()
    }
    
    @IBAction func sendRequest(_ sender: Any) {
        sendTestRequests()
    }
    
    @IBAction func proxyEnabledSwitchChanged(_ sender: UISwitch) {
        sender.isOn ? HTTPProxy.shared.enable() : HTTPProxy.shared.disable()
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) {
        interval = sender.value/10
        let str = String(format: "%.01f", interval)
        intervalLabel.text = str
    }
    
    @IBAction func sendPeriodicallyWwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            if #available(iOS 10.0, *) {
                timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.interval), repeats: true) { _ in
                    self.sendTestRequests()
                }
            }
        } else {
            timer?.invalidate()
            timer = nil
        }
    }
    
    @IBAction func darkModeSwitchChanged(_ sender: UISwitch) {
        let colorScheme: ColorScheme = sender.isOn ? DarkColorScheme() : LightColorScheme()
        HTTPProxyUI.settings = DefaultUISettings(colorScheme: colorScheme)
    }
    
    func darkModeEnabled() -> Bool {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
        return false
    }
    
    func sendTestRequests() {
        sendPut()
        sendGet()
        sendGetWithParameters()
        sendPost()
        sendDelete()
        sendPatch()
        sendGet401()
        getXml()
        getHtml()
        getYml()
        getRepos()
    }
    
    func sendPost() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
        var request = URLRequest(url: url)
        
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("Lorem ipsum dolor sit amet, consectetur adipiscing elit", forHTTPHeaderField: "Curabitur ut auctor lorem. Quisque sed sagittis dolor. Aenean quis ultricies ipsum.")

        request.httpMethod = "POST"
        let json: [String: Any] = ["foo": "bar",
                                   "abc": ["1": "First", "2": "Second"]]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        sendRequest(request)
    }
    
    func sendPut() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
        var request = URLRequest(url: url)
        
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "PUT"
        let json: [String: Any] = ["foo": "bar",
                                   "abc": ["1": "First", "2": "Second"]]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        sendRequest(request)
    }
    
    func sendPatch() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1")!
        var request = URLRequest(url: url)
        
        request.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        let json: [String: Any] = ["title": "bar"]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        sendRequest(request)
    }
    
    func sendGet() {
        let url = URL(string: "https://postman-echo.com/delay/3")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        sendRequest(request)
    }
    
    func sendGetWithParameters() {
        let url = URL(string: "http://postman-echo.com/get?foo1=bar1&foo2=bar2")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        sendRequest(request)
    }

    func sendGet401() {
        let url = URL(string: "https://postman-echo.com/status/401")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        sendRequest(request)
    }

    func sendDelete() {
        let url = URL(string: "https://jsonplaceholder.typicode.com/posts/0")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        sendRequest(request)
    }
    
    func getXml() {
        let url = URL(string: "https://schemas.xmlsoap.org/soap/envelope/")!
        let request = URLRequest(url: url)
        sendRequest(request)
    }
    
    func getRepos() {
        let url = URL(string: "https://api.github.com/repositories")!
        let request = URLRequest(url: url)
        sendRequest(request)
    }
    
    func getHtml() {
        let url = URL(string: "https://raw.githubusercontent.com/GoogleChrome/samples/gh-pages/index.html")!
        let request = URLRequest(url: url)
        sendRequest(request)
    }
    
    func getYml() {
        let url = URL(string: "https://raw.githubusercontent.com/GoogleChrome/samples/gh-pages/.travis.yml")!
        let request = URLRequest(url: url)
        sendRequest(request)
    }
    
    func sendRequest(_ request: URLRequest) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let task = URLSession.shared.dataTask(with: request)
            task.resume()
        }
    }
}

extension ViewController: HTTPProxyDelegate {

    func shouldFireURLRequest(_ urlRequest: URLRequest) -> Bool {
        return true
    }
    
    func willFireRequest(_ httpRequest: HTTPRequest) {
        print("Requesting \(httpRequest.description)")
    }
    
    func didCompleteRequest(_ httpRequest: HTTPRequest) {
        print("Completed \(httpRequest.description)")
    }
}
