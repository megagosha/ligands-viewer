import Foundation

struct Ligand: Codable, Identifiable {
    let meta: Metadata
    let atomsCount: Int
    let bondsCount: Int
    let atomListsCount: Int
    let isChiral: Bool
    let atoms: [AtomLigand]
    let bonds: [Bond]
    var id: String { meta.name }
    
    init(_ data: String) {
        let dataLines = data.components(separatedBy: .newlines)
        meta = Metadata(dataLines)
        let countLine = Ligand.parseCountLine(dataLines)
        atomsCount = countLine.0
        bondsCount = countLine.1
        atomListsCount = countLine.2
        isChiral = countLine.3

        atoms = Ligand.parseAtoms(dataLines, atomsCount: atomsCount)
        bonds = Ligand.parseBonds(dataLines, atoms: atoms, atomsCount: atomsCount, bondsCount:  bondsCount)
    }
    
    private static func parseCountLine(_ dataLines: [String])->(Int, Int, Int, Bool)
    {
        
        let lineArgs = Parser.splitBy(line: dataLines[3], type: .count)
        if lineArgs.count < 1 {
            print(dataLines)
        }
//        let lineArgs = dataLines[3].split(separator: " ", omittingEmptySubsequences: true)
        let numAtoms = Int(lineArgs[0]) ?? 0
        let numBonds = Int(lineArgs[1]) ?? 0
        let numAtomLists = Int(lineArgs[2]) ?? 0
        //3 is obsolete
        let isChiral = (Int(lineArgs[4]) == 1)
        return (numAtoms, numBonds, numAtomLists, isChiral)
    }
    
    private static func parseAtoms(_ dataLines: [String], atomsCount: Int)->[AtomLigand] {
        let lastAtomLine = atomsCount + 3
        var atomLigands: [AtomLigand] = []

        for ix in 4...lastAtomLine {
            atomLigands.append(AtomLigand(line: dataLines[ix]))
        }
        return atomLigands
    }
    
    private static func parseBonds(_ dataLines: [String], atoms: [AtomLigand], atomsCount: Int, bondsCount: Int)->[Bond] {
        let firstBondLine = atomsCount + 4
        let lastBondLine = atomsCount + 3 + bondsCount
        var bonds: [Bond] = []
        if firstBondLine > lastBondLine {
            return []
        }
        for ix in firstBondLine...lastBondLine {
            bonds.append(Bond(line: dataLines[ix], atoms: atoms))
        }
        return bonds
    }
}

struct Metadata: Codable {
    let name: String
    let other: String
    
    init(_ rows: [String]) {
        name = rows[0]
        other = rows[1] + rows[3]
    }
}
