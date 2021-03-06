import UIKit

protocol HeadersListControllerDelegate: class {

    func didSelectItem(at indexPath: IndexPath)
}
    
class HeadersListController: NSObject {

    static let cellIdentifier = "RequestDetailsViewCellId"

    private var tableView: UITableView
    private var dataSource: HeadersListDataSource?
    
    weak var delegate: HeadersListControllerDelegate?
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()

        let nib = UINib(nibName: "RequestsListCell", bundle: HTTPProxyUI.bundle)
        tableView.register(nib, forCellReuseIdentifier: HeadersListController.cellIdentifier)

        UITableViewHeaderFooterView.appearance().tintColor = .clear
        UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = HTTPProxyUI.settings.colorScheme.primaryTextColor
    }
    
    func load(sections: [SearchableListSection]) {
        load(sections: sections, textToHighlight: nil)
    }
    
    func load(sections: [SearchableListSection], textToHighlight: String?) {
        DispatchQueue.main.async {
            self.dataSource = HeadersListDataSource(sections: sections, textToHighlight: textToHighlight)
            self.dataSource?.delegate = self.delegate
            self.tableView.dataSource = self.dataSource
            self.tableView.delegate = self.dataSource
            self.tableView.reloadData()
        }
    }
}

class HeadersListDataSource: NSObject {

    var sections: [SearchableListSection] = []
    let textToHighlight: String?
    weak var delegate: HeadersListControllerDelegate?
    
    init(sections: [SearchableListSection], textToHighlight: String?) {
        self.sections = sections
        self.textToHighlight = textToHighlight
        super.init()
    }
}

extension HeadersListDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HeadersListController.cellIdentifier, for: indexPath) as? RequestsListCell else {
            fatalError()
        }
        
        cell.configure(with: sections[indexPath.section].items[indexPath.row])
        if let text = textToHighlight {
            cell.emphasize(text: text)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].header
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let style: UIBlurEffect.Style = HTTPProxyUI.darkModeEnabled() ? .dark : .extraLight
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.8
        let header = view as! UITableViewHeaderFooterView
        header.backgroundView = blurView
    }
}

extension HeadersListDataSource: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectItem(at: indexPath)
    }
}
