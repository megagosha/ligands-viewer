

import Foundation


class Parser {
    
    enum LineType {
        case count, atom, bond
    }
    
    static let countLine =  [3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 6]
    static let atomLine = [10, 10, 10, 1, 3, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3]
    static let bondLine = [3, 3, 3, 3, 3, 3, 3]
    
    private static func getSi(type: LineType)->[Int] {
        switch type {
        case .count:
            return Parser.countLine
        case .atom:
            return Parser.atomLine
        case .bond:
            return Parser.bondLine
        }
    }
    
    private static func validateLength(type: LineType, str: String)->Bool {
        switch type {
        case .count:
            return str.count == 39
        case .atom:
            return str.count == 69
        case .bond:
            return str.count == 21
        }
    }
    
    static func splitBy(line: String, type: LineType)->[String] {
        var res: [String] = []
        let si = Parser.getSi(type: type)
        if !Parser.validateLength(type: type, str: line) {
            return []
        }
        var ix = 0
        for el in si {
            if  (ix + el) > line.count {
                return []
            }
            let start = line.index(line.startIndex, offsetBy: ix)
            let end = line.index(line.startIndex, offsetBy: ix + el)
            let str = String(line[start..<end]).trimmingCharacters(in: .whitespaces)
            if !str.isEmpty {
                res.append(String(line[start..<end]).trimmingCharacters(in: .whitespaces))
            }
            ix += el
        }
        
        return res
    }
    
}
