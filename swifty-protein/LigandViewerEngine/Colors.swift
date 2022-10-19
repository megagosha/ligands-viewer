import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

class Colors {
    var colors: [String: float3]  = getBaseColors()
    var usedColors: [float3: [String]] = [:]
    var pinkIsUsed = false
    
    func getColor(el: String)->float3 {
        var color = colors[el]
        
        if color == nil && pinkIsUsed {
            color = getRandomColor()
            colors[el] = color
            return color!
        }
        else if color == nil {
            //cpk uses pink for undefined elements
            color = Color.pink.rgb
            pinkIsUsed = true
            return color!
        }
        return color!
    }
    
    static func darker(c: float3, t: Int)->float3 {
        return float3(c.x + 0.05 * Float(t), c.y + 0.05 * Float(t), c.z + 0.05 * Float(t))
    }
    
    private func getRandomColor() -> float3 {
        return float3(Float.random(in: 0..<1), Float.random(in: 0..<1), Float.random(in: 0..<1))
    }
    
    private static func getBaseColors()->[String:float3] {
        return [
            "H": Color.white.rgb,
            "C": Color.gray.rgb,
            "N": Color.blue.rgb,
            "O": Color.red.rgb,
            "F": Color.green.rgb,
            "Cl": Color.green.rgb,
            "Br": Color.darkRed.rgb,
            "I": Color.darkViolet.rgb,
            "He": Color.cyann.rgb,
            "Ne": Color.cyann.rgb,
            "Ar": Color.cyann.rgb,
            "Kr": Color.cyann.rgb,
            "Xe": Color.cyann.rgb,
            "P": Color.orange.rgb,
            "S": Color.yellow.rgb,
            "B": Color.beige.rgb,
            "Li": Color.violet.rgb,
            "Na": Color.violet.rgb,
            "K": Color.violet.rgb,
            "Rb": Color.violet.rgb,
            "Cs": Color.violet.rgb,
            "Fr": Color.violet.rgb,
            "Be": Color.darkGreen.rgb,
            "Mg": Color.darkGreen.rgb,
            "Ca": Color.darkGreen.rgb,
            "Sr": Color.darkGreen.rgb,
            "Ba": Color.darkGreen.rgb,
            "Ra": Color.darkGreen.rgb,
            "Ti":Color.gray.rgb,
            "Fe": Color.darkOrange.rgb,
            "": Color.pink.rgb
        ]
    }
}

extension Color {
    static let darkRed = Color(red: 255 * 0.7, green: 255 * 0.3, blue: 255 * 0.1)
    static let darkViolet = Color(red: 255 * 0.7, green: 0, blue: 255 * 0.7)
    static let beige = Color(red: 255 * 0.5, green: 255 * 0.5, blue: 255 * 0.1)
    static let violet = Color(red: 255 * 0.9, green: 255 * 0.5, blue: 255 * 0.8)
    static let darkGreen = Color(red: 255 * 0.5, green: 255 * 0.5, blue: 255 * 0.1)
    static let darkOrange = Color(red: 255 * 1, green: 255 * 0.6, blue: 255 * 0.2)
    static let cyann = Color(red: 255 * 0.6, green: 255 * 1, blue: 255 * 1)
    var rgb: float3 {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0
#if canImport(UIKit)
        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &o)
#elseif canImport(AppKit)
        NSColor(self).usingColorSpace(NSColorSpace.extendedSRGB)?.getRed(&r, green: &g, blue: &b, alpha: &o)
#endif
        return float3(Float(r), Float(g), Float(b))
    }
}

