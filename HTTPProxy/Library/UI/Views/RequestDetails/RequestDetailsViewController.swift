import UIKit

protocol RequestDetailsViewControllerDelegate: class {

    func viewController(index: Int) -> UIViewController
}

class RequestDetailsViewController: UIViewController {

    var delegate: RequestDetailsViewControllerDelegate!

    @IBOutlet private var segmentedControl: UISegmentedControl!
    @IBOutlet private var contentView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = HTTPProxyUI.colorScheme.backgroundColor
        segmentedControl.backgroundColor = HTTPProxyUI.colorScheme.foregroundColor
        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = HTTPProxyUI.colorScheme.selectedColor
            
            let selectedAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white
            ]
            let normalAttributes = [
                NSAttributedString.Key.foregroundColor: HTTPProxyUI.colorScheme.secondaryTextColor
            ]
            segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
            segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
        } else {
            segmentedControl.tintColor = HTTPProxyUI.colorScheme.selectedColor
        }

        updateChildViewController(0)
    }

    @IBAction private func selectedAction() {
        updateChildViewController(segmentedControl.selectedSegmentIndex)
    }

    private func updateChildViewController(_ index: Int) {
        let old = children.first
        let new = delegate.viewController(index: index)

        old?.willMove(toParent: nil)
        addChild(new)

        old?.view.removeFromSuperview()

        contentView.addSubview(new.view)
        var frame = contentView.frame
        frame.origin = CGPoint.zero
        new.view.frame = frame

        new.didMove(toParent: self)
        old?.removeFromParent()
    }
}
