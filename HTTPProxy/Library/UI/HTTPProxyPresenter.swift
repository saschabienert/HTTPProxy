import UIKit

class HTTPProxyPresenter {

    private var requestsListPresenter: RequestsListPresenter?
    private var coordinator: MainCoordinator?
    static let shared = HTTPProxyPresenter()
    
    func handleShakeGesture() {
        presentViewController()
    }
    
    func presentViewController() {
        guard let coordinator = coordinator else {
            showRequestsList()
            return
        }
        
        coordinator.dismiss()
    }
    
    func showRequestsList() {
        guard let topViewController = topViewController() else {
            return
        }
        coordinator = MainCoordinator(navigationController: UINavigationController(), topViewController: topViewController)
        coordinator?.delegate = self
        coordinator?.start()
    }

    private func topViewController() -> UIViewController? {
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        return topViewController
    }
}

extension HTTPProxyPresenter: CoordinatorDelegate {
    func didDismiss() {
        coordinator = nil
    }
}
