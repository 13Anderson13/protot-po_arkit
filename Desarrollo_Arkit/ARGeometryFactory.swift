//
//  ARGeometryFactory.swift
//  Desarrollo_Arkit
//
//  Fábrica de geometrías 3D utilizando SceneKit para ARKit.
//

import UIKit
import SceneKit
import ARKit

/// Generador de nodos 3D para cada tipo de figura en el espacio ARKit
final class ARGeometryFactory {

    /// Crea el nodo 3D configurado con materiales e iluminación según la figura solicitada.
    static func createNode(for shape: ARShapeType) -> SCNNode {
        let geometry: SCNGeometry

        switch shape {
        case .sphere:
            // Esfera de 12 cm de radio (24 cm de diámetro en el mundo real)
            let sphere = SCNSphere(radius: 0.12)
            sphere.segmentCount = 64 // Alta resolución de polígonos para curva suave
            geometry = sphere

        case .prism:
            // Prisma triangular equilátero extruido
            let side: CGFloat = 0.22
            let height: CGFloat = side * (sqrt(3.0) / 2.0)

            let path = UIBezierPath()
            // Centrado en el baricentro del triángulo
            path.move(to: CGPoint(x: -side / 2.0, y: -height / 3.0))
            path.addLine(to: CGPoint(x: side / 2.0, y: -height / 3.0))
            path.addLine(to: CGPoint(x: 0, y: 2.0 * height / 3.0))
            path.close()

            let prism = SCNShape(path: path, extrusionDepth: 0.22)
            prism.chamferRadius = 0.006 // Suavizado en las aristas
            geometry = prism

        case .cube:
            // Cubo de 20 cm por lado con esquinas suavemente biseladas
            let box = SCNBox(width: 0.20, height: 0.20, length: 0.20, chamferRadius: 0.012)
            geometry = box
        }

        // Configuración de materiales basados en física (PBR / Iluminación realista)
        let material = SCNMaterial()
        material.diffuse.contents = shape.uiColor
        material.specular.contents = UIColor.white
        material.shininess = 60.0
        material.roughness.contents = NSNumber(value: 0.25)
        material.metalness.contents = NSNumber(value: 0.15)
        material.isDoubleSided = true

        geometry.materials = [material]

        let node = SCNNode(geometry: geometry)
        node.name = "ARSelectedShapeNode"

        // Centrado del punto de pivote para que rote sobre su centro exacto
        let (minVec, maxVec) = node.boundingBox
        node.pivot = SCNMatrix4MakeTranslation(
            (maxVec.x + minVec.x) / 2.0,
            (maxVec.y + minVec.y) / 2.0,
            (maxVec.z + minVec.z) / 2.0
        )

        return node
    }

    /// Acción de rotación suave y continua sobre el eje Y
    static func createGentleRotationAction(duration: TimeInterval = 10.0) -> SCNAction {
        let rotate = SCNAction.rotateBy(x: 0, y: CGFloat.pi * 2, z: 0, duration: duration)
        return SCNAction.repeatForever(rotate)
    }

    /// Acción de "salto" o rebote cuando el usuario toca la figura en la pantalla
    static func createBounceAction() -> SCNAction {
        let jumpUp = SCNAction.moveBy(x: 0, y: 0.06, z: 0, duration: 0.15)
        jumpUp.timingMode = .easeOut

        let spin = SCNAction.rotateBy(x: 0, y: CGFloat.pi / 2, z: 0, duration: 0.3)
        spin.timingMode = .easeInEaseOut

        let jumpDown = SCNAction.moveBy(x: 0, y: -0.06, z: 0, duration: 0.2)
        jumpDown.timingMode = .easeIn

        let jumpGroup = SCNAction.sequence([jumpUp, jumpDown])
        return SCNAction.group([jumpGroup, spin])
    }
}

