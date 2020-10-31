import Foundation
import UIKit

class RequestsListCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    weak var delegate: CoordinatorDelegate?
    
    private let requestsViewController: RequestsListViewController
    private weak var presentingViewController: UIViewController?
    weak var parentCoordinator: MainCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.requestsViewController = UIStoryboard(name: "RequestsListViewController", bundle: HTTPProxyUI.bundle).instantiateInitialViewController() as! RequestsListViewController
        self.requestsViewController.requestsListViewOutput = self
        self.requestsViewController.viewModel = RequestsListViewModel()
    }
    
    func start() {
        let navigationBar = navigationController.navigationBar
        navigationBar.isTranslucent = false
        navigationBar.tintColor = HTTPProxyUI.settings.colorScheme.primaryTextColor
        navigationBar.barTintColor = HTTPProxyUI.settings.colorScheme.foregroundColor
        navigationBar.titleTextAttributes = [.foregroundColor: HTTPProxyUI.settings.colorScheme.primaryTextColor]

        navigationController.modalPresentationStyle = .fullScreen
        requestsViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(close))
        let filterButton =  UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createFilter))
        let clearButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(clear))
        requestsViewController.navigationItem.rightBarButtonItems = [clearButton, filterButton]
    
        navigationController.pushViewController(requestsViewController, animated: true)
    }
    
    @objc func close() {
        requestsViewController.dismiss(animated: true) {
              self.delegate?.didDismiss()
        }
    }
    
    @objc func createFilter() {
        editOrCreateFilter()
    }
    
    @objc func clear() {
        requestsViewController.clearRequests()
    }
    
    private func editOrCreateFilter(filter: HTTPProxyFilter? = nil) {
        let filterVC = UIStoryboard(name: "EditFilterViewController", bundle: HTTPProxyUI.bundle).instantiateInitialViewController() as! EditFilterViewController
        filterVC.delegate = self
        filterVC.filter = filter
        navigationController.pushViewController(filterVC, animated: true)
    }
}

extension RequestsListCoordinator: RequestsListViewOutput {
    
    func requestSelected(_ request: HTTPRequest) {
        parentCoordinator?.details(request: request)
    }
    
    func editFilter(_ filter: HTTPProxyFilter) {
        editOrCreateFilter(filter: filter)
    }
}

extension RequestsListCoordinator: EditFilterViewControllerDelegate {
    func editFilterViewController(_ viewController: EditFilterViewController, didEditFilter filter: HTTPProxyFilter) {
        if viewController.filter == nil {
            requestsViewController.addFilter(filter)
        } else {
            requestsViewController.reloadFilters()
        }
        navigationController.popViewController(animated: true)
    }
}
