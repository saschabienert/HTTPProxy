import UIKit

@IBDesignable class RoundedLabel: UILabel {

    override func layoutSubviews() {
        super.layoutSubviews()

        self.textAlignment = .center
        updateCornerRadius()
    }

    @IBInspectable var cornerRadius: CGFloat = 8 {
        didSet {
            updateCornerRadius()
        }
    }

    func updateCornerRadius() {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = cornerRadius > 0
    }

    var edgeInsets: UIEdgeInsets {
        let inset = cornerRadius / 2
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: edgeInsets))
    }

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize

        let edgeInsets = self.edgeInsets
        size.width += edgeInsets.left + edgeInsets.right
        size.height += edgeInsets.top + edgeInsets.bottom

        return size
    }
}
