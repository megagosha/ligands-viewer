import MetalKit

struct LigandScene {
    
    var lighting = SceneLighting()
    
    var models: [Model] = []
    var camera = ArcballCamera()
    var colors: [String:float3] = [:]
    var colorGenerator = Colors()
    var ligand: Ligand?
    var quat: simd_quatf?
    
    init(ligand: Ligand?) {
        self.ligand = ligand
        camera.position = [0, 1.5, -20]
                camera.distance = length(camera.position)
                camera.target = [0, 0, 0]
        guard let ligand = ligand else {
            return
        }
        createModels(from: ligand)
    }
    
    private mutating func createModels(from ligand: Ligand) {
        generateColors(ligand)
        for (ix, atom) in ligand.atoms.enumerated() {
            //            if (ix > 1) {
            //                break
            //            }
            createAtom(atom: atom, id: UInt32(ix + 1))
        }
        calculateInitialCameraPosition()
        for (ix, conn) in ligand.bonds.enumerated() {
            //                        if ix > 1 {
            //                            return
            //                        }
            createConnection(connection: conn, id: UInt32((ix + 1) + ligand.atoms.count))
        }
    }
    private func updateMinMax( min: inout float3, max: inout float3, target: float3)
    {
        if min.x > target.x {
            min.x = target.x
        }
        if max.x < target.x {
            max.x = target.x
        }
        if min.y > target.y {
            min.y = target.y
        }
        if max.y < target.y {
            max.y = target.y
        }
        if min.z > target.z {
            min.z = target.z
        }
        if max.z < target.z {
            max.z = target.z
        }
    }
    
    private mutating func calculateInitialCameraPosition() {
        var camPos = float3()
        var mins = float3()
        var maxs = float3()
        for mod in models {
            let pos = mod.position
            camPos += pos
            updateMinMax(min: &mins, max: &maxs, target: pos)
        }
        let count = Float(models.count)
        camPos = camPos / count
        camera.distance = distance(mins, maxs)
        if camera.distance > camera.maxDistance {
            camera.maxDistance = camera.maxDistance * 1.5
        }
        camera.target = camPos
    }
    
    private mutating func generateColors(_ ligand: Ligand) {
        for atom in ligand.atoms {
            if colors[atom.symbol] == nil {
                colors[atom.symbol] = colorGenerator.getColor(el: atom.symbol)
            }
        }
    }
    
    private func getRandomColor() -> float3 {
        return float3(Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1))
    }
    
    private
    mutating func createAtom(atom: AtomLigand,id: UInt32) {
        var sphere = Atom(name: atom.symbol, id: id, color: colors[atom.symbol]!)
        //        var sphere = Atom(name: atom.symbol, id: id)
        //        sphere.createSphere()
        sphere.position.z = atom.pos[2]
        sphere.position.y = atom.pos[1]
        sphere.position.x = atom.pos[0]
        //        sphere.color = colors[atom.symbol]!
        self.models.append(sphere)
    }
    
    
    private mutating func createConnection(height: Float, symbol: String, id: UInt32, pos: float3, rotation: float4x4, isDouble: Bool) {
        var conn = Cylinder(height: height, name: "Bond \(symbol)", color: colors[symbol]!, id: id, isDouble: isDouble)
        conn.position = pos
//        conn.rotation = [0, Float.pi, 0]
        conn.rotationMatrix = rotation * float4x4(rotation: float3(0, Float.pi, 0))
        if isDouble {
            conn.position.z += 0.13
            var conn2 = Cylinder(height: height, name: "Bond \(symbol)", color: colors[symbol]!, id: id, isDouble: isDouble)
            conn2.position = pos
            conn2.position.z -= 0.13
//            conn2.rotation = [0, Float.pi, 0]
            conn2.rotationMatrix = rotation * float4x4(rotation: float3(0, Float.pi, 0))
            models.append(conn2)
        }
        //        print("model \(conn.transform.modelMatrix) \(isDouble)")
        //        print("normal m \(conn.transform.modelMatrix.upperLeft)")
        self.models.append(conn)
    }
    
    private
    mutating func createConnection(connection: Bond, id: UInt32) {
        let height = calculateDistance(bond: connection) / 2
        
        let calc = getBondPositionAndColor(aAtom: connection.first, bAtom: connection.second, height)
        let calc2 = getBondPositionAndColor(aAtom: connection.second, bAtom: connection.first, height)
        
        createConnection(height: height, symbol: connection.first.symbol, id: id, pos: calc.0, rotation: calc.1, isDouble: connection.type == .double)
        createConnection(height: height, symbol: connection.second.symbol, id: id, pos: calc2.0, rotation: calc2.1, isDouble: connection.type == .double)
    }
    
    private func calculateDistance(bond: Bond)->Float {
        let a = bond.first.pos
        let b = bond.second.pos
        return sqrt(pow(b[0] - a[0], 2) + pow(b[1] - a[1], 2) + pow(b[2] - a[2], 2))
    }
    
    mutating func update(deltaTime: Float) {
        camera.update(deltaTime: deltaTime)
        lighting.lights[0].position = camera.position * 3
        let rotationP = float3(x: 1, y: 1, z: 1)
        let input = InputController.shared
        let scrollSensitivity = Settings.mouseScrollSensitivity
    
        input.mouseScroll = .zero
        if input.leftMouseDown {
            let sensitivity = Settings.mousePanSensitivity
            input.mouseDelta = .zero
        }
    }
    
    mutating func update(size: CGSize) {
        camera.update(size: size)
    }
    
    private func rotateMatrix(v1: float3, v2: float3)->float4x4
    {
        let axis: float3 = cross(v1, v2);
        var  cosA: Float = dot( v1, v2 );
        let  k = 1.0 / (1.0 + cosA);
        if k.isInfinite {
            print("K IS INFINITY")
        }
        
        let result = float4x4( [(axis.x * axis.x * k) + cosA,
                                (axis.y * axis.x * k) - axis.z,
                                (axis.z * axis.x * k) + axis.y, 0],
                               [(axis.x * axis.y * k) + axis.z,
                                (axis.y * axis.y * k) + cosA,
                                (axis.z * axis.y * k) - axis.x, 0],
                               [(axis.x * axis.z * k) - axis.y,
                                (axis.y * axis.z * k) + axis.x,
                                (axis.z * axis.z * k) + cosA, 0],
                               [0,0,0,1]
        );
        return result;
    }
    
    public func selectAtom(fromId id: UInt32)->AtomLigand? {
        guard let atoms = ligand?.atoms else {
            return nil
        }
        let id = Int(id)
        if id <= atoms.count && id > 0 {
            return atoms[id - 1]
        }
        return nil
    }
    
    private func getBondPositionAndColor(aAtom: AtomLigand, bAtom: AtomLigand, _ height: Float)->(float3, float4x4) {
        let a = aAtom.pos
        let b = bAtom.pos
        let middle = [(b[0] + a[0]) / 2, (b[1] + a[1]) / 2, (b[2] + a[2]) / 2]
        let pos = float3(x: (a[0] + middle[0]) / 2 , y: (a[1] + middle[1]) / 2, z: (a[2] + middle[2]) / 2)
        let vNorm = float3(x: (a[0] - middle[0]) / height, y: (a[1] - middle[1]) / height, z: (a[2] - middle[2])/height)
        let orig = float3(0, 1, 0)
        //        print("v1 \(vNorm) v2 \(orig)")
        let rotation = rotateMatrix(v1: vNorm, v2: orig)
        return (pos, rotation)
    }
}
