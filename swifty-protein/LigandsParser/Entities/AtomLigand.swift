import Foundation


struct AtomLigand: Codable, Equatable {
    var pos: [Float] //xyz
    let symbol: String // * unspecified, LP lone pair or R#
    let massDiff: Int
    let charge: Int
    let sp: StereoParity
    let hydrogen: HydrogenCount
    let sc: StereoCare
    let valence: Int
    let isHforbidden: Bool // = false by default 1 - not allowed, 0 not specified
    //skip next 2
    let numberOfAtoms: Int
    let inversion: Inversion
    let isExactChange: Bool
    
    init(line: String) {
        let ap = Parser.splitBy(line: line, type: .atom)
        pos = [
            Float(ap[0]) ?? 0,
            Float(ap[1]) ?? 0,
            Float(ap[2]) ?? 0
        ]
        symbol = String(ap[3])
        massDiff = Int(ap[4]) ?? 0
        charge = Int(ap[5]) ?? 0
        sp = StereoParity(rawValue: Int(ap[6]) ?? 0)!
        hydrogen = HydrogenCount(rawValue: Int(ap[7]) ?? 1)!
        sc = StereoCare(rawValue: Int(ap[8]) ?? 0)!
        valence = Int(ap[9]) ?? 0
        isHforbidden = Bool(String(ap[10])) ?? false
        numberOfAtoms = Int(ap[13]) ?? 0
        inversion = Inversion(rawValue: Int(ap[14]) ?? 0)!
        isExactChange =  Bool(String(ap[15])) ?? false
    }
    static func == (lhs: AtomLigand, rhs: AtomLigand) -> Bool {
        return lhs.pos == rhs.pos && lhs.symbol == rhs.symbol
    }
}

enum StereoParity: Int, Codable {
    case notStereo = 0, odd, even, either
}

enum HydrogenCount: Int, Codable {
    case unset = 0, h0, h1, h2, h3, h4
}

enum StereoCare: Int, Codable {
    case ignore = 0, stereo
}

enum Inversion: Int, Codable {
    case notApplied = 0, inverted, retained
}

