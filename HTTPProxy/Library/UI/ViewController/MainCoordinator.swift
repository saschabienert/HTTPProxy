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
        let coordinator = RequestsListCoordinator(navigationController: navigationController)
        coordinator.delegate = self
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
        coordinator.start()
        topViewController.present(navigationController, animated: true, completion: nil)
    }
    
    func dismiss() {
        navigationController.dismiss(animated: true) {
            self.delegate?.didDismiss()
        }
    }
    
    func details(request: HTTPRequest) {
        let coordinator = RequestDetailsCoordinator(request: request, navigationController: navigationController)
        coordinator.delegate = self
        childCoordinators.append(coordinator)
        coordinator.start()
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
