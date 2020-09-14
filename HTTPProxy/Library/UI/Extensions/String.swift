import Foundation

extension String {

    func ranges(of searchString: String) -> [NSRange]? {
        let count = searchString.count
        guard let indices = indices(of: searchString) else {
            return nil
        }

        let ranges = indices.map({ index(startIndex, offsetBy: $0)..<index(startIndex, offsetBy: $0+count) })
        return ranges.map({NSRange($0, in: self)})
    }

    func indices(of occurrence: String) -> [Int]? {
        var indices = [Int]()
        var position = startIndex
        while let range = range(of: occurrence, range: position..<endIndex) {
            let dist = distance(from: startIndex, to: range.lowerBound)
            indices.append(dist)
            let offset = occurrence.distance(from: occurrence.startIndex, to: occurrence.endIndex) - 1
            guard let after = index(range.lowerBound, offsetBy: offset, limitedBy: endIndex) else {
                break
            }
            position = index(after: after)
        }

        if indices.isEmpty {
            return nil
        }

        return indices
    }
}
