//
//  ARShapeType.swift
//  Desarrollo_Arkit
//
//  Definición de las figuras geométricas disponibles para renderizar con ARKit.
//

import UIKit
import SwiftUI

/// Representa los tipos de figuras tridimensionales disponibles en el prototipo ARKit.
enum ARShapeType: String, CaseIterable, Identifiable {
    case sphere = "Esfera"
    case prism  = "Prisma"
    case cube   = "Cubo"

    var id: String { rawValue }

    /// Nombre amigable de la figura
    var title: String { rawValue }

    /// Breve descripción geométrica y educativa
    var subtitle: String {
        switch self {
        case .sphere:
            return "Cuerpo geométrico redondo con simetría perfecta en 360°"
        case .prism:
            return "Prisma triangular con 5 caras, 6 vértices y 9 aristas"
        case .cube:
            return "Poliedro regular compuesto por 6 caras cuadradas congruentes"
        }
    }

    /// Explicación pedagógica para entender el renderizado en ARKit
    var arExplanation: String {
        switch self {
        case .sphere:
            return "ARKit renderiza una superficie curva continua calculando las normales de iluminación en cada punto de la esfera (SCNSphere) adaptándose a la luz ambiental."
        case .prism:
            return "Construido a partir de una sección triangular extruida (SCNShape). Muestra cómo ARKit y SceneKit calculan aristas y reflejos en caras poligonales."
        case .cube:
            return "Geometría básica (SCNBox) con aristas biseladas. Permite visualizar claramente las 3 dimensiones (X, Y, Z) en el espacio del mundo real."
        }
    }

    /// Ícono representativo del sistema SF Symbols
    var iconName: String {
        switch self {
        case .sphere:
            return "globe.americas.fill"
        case .prism:
            return "pyramid.fill"
        case .cube:
            return "cube.fill"
        }
    }

    /// Color temático primario
    var uiColor: UIColor {
        switch self {
        case .sphere:
            return UIColor(red: 0.18, green: 0.60, blue: 0.95, alpha: 1.0) // Azul brillante
        case .prism:
            return UIColor(red: 0.65, green: 0.25, blue: 0.90, alpha: 1.0) // Violeta vibrante
        case .cube:
            return UIColor(red: 0.98, green: 0.50, blue: 0.15, alpha: 1.0) // Naranja cálido
        }
    }

    var swiftUIColor: Color {
        Color(uiColor)
    }

    /// Gradiente representativo para la tarjeta del menú
    var gradientColors: [Color] {
        switch self {
        case .sphere:
            return [Color.blue, Color.cyan]
        case .prism:
            return [Color.purple, Color.indigo]
        case .cube:
            return [Color.orange, Color.red]
        }
    }
}

