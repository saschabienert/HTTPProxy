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
        return UIEdgeInsets(top: cornerRadius, left: cornerRadius, bottom: cornerRadius, right: cornerRadius)
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
