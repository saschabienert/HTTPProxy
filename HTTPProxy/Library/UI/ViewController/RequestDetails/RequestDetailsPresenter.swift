import Foundation
import UIKit

private struct RequestFields: SearchableListItem {
    
    let key: String
    let value: String
    
    var method: String? {
        return nil
    }
    var statusCode: Int? {
        return nil
    }
    var requestStatus: RequestStatus? {
        return nil
    }
}

class RequestDetailsPresenter {
    private let request: HTTPRequest
    private let viewController: RequestDetailsViewController
    private let presentingViewController: UINavigationController
    private var viewControllers: [UIViewController] = []
    
    init(request: HTTPRequest, presentingViewController: UINavigationController) {
        self.request = request
        self.presentingViewController = presentingViewController
        self.viewController = RequestDetailsViewController(nibName: "RequestDetailsViewController", bundle: HTTPProxyUI.bundle)
        self.viewController.delegate = self
        let title = request.request.url?.host ?? "Request Details"
        self.viewController.title = title
        
        let vc1 = Summary().requestController(httpRequest: request)
        let vc2 = Request(presenter: self).requestController(httpRequest: request)
        let vc3 = Response(presenter: self).requestController(httpRequest: request)
        self.viewControllers.append(vc1)
        self.viewControllers.append(vc2)
        self.viewControllers.append(vc3)
    }
    
    func present() {
        self.presentingViewController.pushViewController(viewController, animated: true)
    }
    
    func openTextViewer(text: String, filename: String) {
        let nibName = String(describing: TextViewerViewController.self)
        let textViewer = TextViewerViewController(nibName: nibName, bundle: HTTPProxyUI.bundle)
        let color = HTTPProxyUI.colorScheme.highlightedTextColor
        let viewModel = TextViewerViewModel(text: text, filename: filename, highlightedTextColor: color)
        textViewer.viewModel = viewModel
        textViewer.modalPresentationStyle = .fullScreen
        presentingViewController.pushViewController(textViewer, animated: true)
    }
}

extension RequestDetailsPresenter: RequestDetailsViewControllerDelegate {
    func viewController(index: Int) -> UIViewController {
        return viewControllers[index]
    }
}

private struct Summary {
    
    func requestController(httpRequest: HTTPRequest) -> SearchableListViewController {
        let viewController = SearchableListViewController(nibName: "SearchableListViewController", bundle: HTTPProxyUI.bundle)
        viewController.sections = sectionData(httpRequest: httpRequest) ?? []
        return viewController
    }
    
    func sectionData(httpRequest: HTTPRequest) -> [SearchableListSection]? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SSS"
        let requestDate = dateFormatter.string(from: httpRequest.requestDate)
        
        var requestData: [(String, String)] = []
        requestData.append(("Request date", requestDate))
        
        if let date = httpRequest.responseDate {
            let responseDate = dateFormatter.string(from: date)
            requestData.append(("Response date", responseDate))
            let interval = String(format: "%.2f ms", date.timeIntervalSince(httpRequest.requestDate))
            requestData.append(("Interval", interval))
        }
        
        if let method = httpRequest.request.httpMethod {
            requestData.append(("Method", method))
        }
        
        requestData.append(("Timeout", "\(httpRequest.request.timeoutInterval)"))
        
        if let response = httpRequest.response {
            var statusCode: Int?
            if case .success(let response, _) = response {
                statusCode = response.statusCode
            } else if case .failure(let response, let error as NSError) = response {
                statusCode = response?.statusCode
                requestData.append(("Error", "\(error.domain)(\(error.code)): \(error.localizedDescription)"))
            }
            if let status = statusCode {
                requestData.append(("Status", "\(status)"))
            }
        }
        
        if let url = httpRequest.request.url {
            requestData.append(("URL", url.absoluteString))
        }
        
        var requestFields: [RequestFields] = []
        for (key, value) in requestData {
            let item = RequestFields(key: key, value: value)
            requestFields.append(item)
        }
        
        let section = SearchableListSection(items: requestFields)
        return [section]
    }
}

private struct Request {
    
    weak var presenter: RequestDetailsPresenter!
    
    init(presenter: RequestDetailsPresenter) {
        self.presenter = presenter
    }
    
    func requestController(httpRequest: HTTPRequest) -> SearchableListViewController {
        let viewController = SearchableListViewController(nibName: "SearchableListViewController", bundle: HTTPProxyUI.bundle)
        
        var requestFields: [RequestFields] = []
        if let allHTTPHeaderFields = httpRequest.request.allHTTPHeaderFields {
            for (key, value) in allHTTPHeaderFields {
                let item = RequestFields(key: key, value: value)
                requestFields.append(item)
            }
        }
        
        let sortedHeaders = requestFields.sorted { field1, field2 -> Bool in
            return field1.key < field2.key
        }
        
        if let bodyString = httpRequest.requestBodyString {
            viewController.buttonTitle = "Show Request Body"
            viewController.buttonCallback = {
                self.presenter.openTextViewer(text: bodyString, filename: "Request Body")
            }
        }
        
        var parameters: [RequestFields] = []
        if let url = httpRequest.request.url,
            let urlComponents = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let queryItems = urlComponents.queryItems, !queryItems.isEmpty {
            for (param) in queryItems {
                let item = RequestFields(key: param.name, value: param.value ?? "")
                parameters.append(item)
            }
        }
        
        let headersSection = SearchableListSection(items: sortedHeaders, title: "Request Headers")
        let paramsSection = SearchableListSection(items: parameters, title: "Query parameters")
        viewController.sections = [headersSection, paramsSection]
        return viewController
    }
}

private struct Response {
    
    weak var presenter: RequestDetailsPresenter!
    
    init(presenter: RequestDetailsPresenter) {
        self.presenter = presenter
    }
    
    func requestController(httpRequest: HTTPRequest) -> SearchableListViewController {
        let viewController = SearchableListViewController(nibName: "SearchableListViewController", bundle: HTTPProxyUI.bundle)
        let headers = sortedHeaders(httpRequest: httpRequest) ?? []
        let paramsSection = SearchableListSection(items: headers, title: "Response Headers")
        viewController.sections = [paramsSection]
        
        if canShowResponse(httpRequest: httpRequest) {
            viewController.buttonTitle = "Show Response Body"
            viewController.buttonCallback = {
                self.showResponse(httpRequest: httpRequest)
            }
        }
        return viewController
    }
    
    func sortedHeaders(httpRequest: HTTPRequest) -> [RequestFields]? {
        guard let urlResponse = httpRequest.response?.urlResponse else {
            return nil
        }
        
        var requestFields: [RequestFields] = []
        for (key, value) in urlResponse.allHeaderFields {
            let item = RequestFields(key: key.description, value: String(describing: value))
            requestFields.append(item)
        }
        
        let sortedHeaders = requestFields.sorted { field1, field2 -> Bool in
            return field1.key < field2.key
        }
        return sortedHeaders
    }
    
    private func canShowResponse(httpRequest: HTTPRequest) -> Bool {
        let isEmpty = httpRequest.response?.responseString?.isEmpty ?? true
        return !isEmpty
    }
    
    private func suggestedFilename(httpRequest: HTTPRequest) -> String? {
        guard case .success(let response, _)? = httpRequest.response else {
            return nil
        }
        return response.suggestedFilename
    }
    
    private func showResponse(httpRequest: HTTPRequest) {
        if let responseString = httpRequest.response?.responseString {
            let filename = suggestedFilename(httpRequest: httpRequest) ?? ""
            viewFile(content: responseString, filename: filename)
        }
    }
    
    private func viewFile(content: String, filename: String) {
        presenter.openTextViewer(text: content, filename: filename)
    }
}
