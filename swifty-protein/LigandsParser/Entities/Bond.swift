struct Bond: Codable {
    var first: AtomLigand
    var second: AtomLigand
    let type: BondType
    let stereo: BondStereo
    let topology: BondTopology
    let reactingStatus: Int
    init(line: String, atoms: [AtomLigand]) {
        let bp = Parser.splitBy(line: line, type: .bond)
        let fa = Int(bp[0]) ?? 1
        let sa = Int(bp[1]) ?? 1
        let t =     float3(1, 1, 1)

        if atoms[fa - 1].pos[0] > atoms[sa - 1].pos[0]
        {
            first = atoms[sa - 1]
            second = atoms[fa - 1]
        }
        else {
            first = atoms[fa - 1]
            second = atoms[sa - 1]
        }
        type = BondType(rawValue: Int(bp[2]) ?? 1)!
        stereo = BondStereo(rawValue: Int(bp[3]) ?? 0)!
        //skip 4 - not used
        topology = BondTopology(rawValue: Int(bp[5]) ?? 0)!
        reactingStatus = Int(bp[6]) ?? 0
    }
    
}

enum BondType: Int, Codable {
    case single = 1, double, tripple, aromatic, singleOrDouble, singleOrAromatic, doubleOrAromatic, anyType
}

enum BondStereo: Int, Codable {
    case notStereo = 0, up, cis, either, down
}

enum BondTopology: Int, Codable {
    case either = 0, ring, chain
}
