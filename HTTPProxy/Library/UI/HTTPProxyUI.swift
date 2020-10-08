import UIKit

protocol UISettings {
    var colorScheme: ColorScheme { get }
    var regularFont: UIFont { get }
    var regularBoldFont: UIFont { get }
}

struct DefaultUISettings: UISettings {
    let colorScheme: ColorScheme
    let regularFont = UIFont(name: "Menlo", size: 14.0)!
    let regularBoldFont = UIFont(name: "Menlo-Bold", size: 14.0)!
}

class HTTPProxyUI {

    static let bundle = Bundle(for: HTTPProxy.self)
    
    static var settings: UISettings = DefaultUISettings(colorScheme: HTTPProxyUI.darkModeEnabled() ? DarkColorScheme() : LightColorScheme())
    
    static func darkModeEnabled() -> Bool {
        if #available(iOS 13.0, *) {
            return UITraitCollection.current.userInterfaceStyle == .dark
        }
        return false
    }
}
