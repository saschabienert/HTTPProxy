import UIKit

protocol CoordinatorDelegate: class {
    func didDismiss()
}

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    var delegate: CoordinatorDelegate? { get set }
    
    func start()
}

class MainCoordinator: Coordinator {
    
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController
    weak var delegate: CoordinatorDelegate?
    let topViewController: UIViewController
    
    init(navigationController: UINavigationController, topViewController: UIViewController) {
        self.navigationController = navigationController
        self.topViewController = topViewController
    }

    func start() {
        let requestsListPresenter = RequestsListPresenter(navigationController: navigationController)
        requestsListPresenter.delegate = self
        requestsListPresenter.parentCoordinator = self
        childCoordinators.append(requestsListPresenter)
        requestsListPresenter.start()
        topViewController.present(navigationController, animated: true, completion: nil)
    }
    
    func dismiss() {
        navigationController.dismiss(animated: true) {
            self.delegate?.didDismiss()
        }
    }
    
    func details(request: HTTPRequest) {
        let presenter = RequestDetailsPresenter(request: request, navigationController: navigationController)
        presenter.delegate = self
        childCoordinators.append(presenter)
        presenter.start()
    }
}

extension MainCoordinator: CoordinatorDelegate {
    func didDismiss() {
        childCoordinators.removeLast()
        if childCoordinators.count == 0 {
            delegate?.didDismiss()
        }
    }
}
