//
//  ARViewContainer.swift
//  Desarrollo_Arkit
//
//  Contenedor UIViewRepresentable que integra ARSCNView y ARSession en SwiftUI.
//

import SwiftUI
import ARKit
import SceneKit

struct ARViewContainer: UIViewRepresentable {
    let shapeType: ARShapeType
    @Binding var isAutoRotating: Bool
    @Binding var trackingStatus: String

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        sceneView.delegate = context.coordinator
        sceneView.session.delegate = context.coordinator

        // Configuración de iluminación para renderizado realista en el mundo físico
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true

        // Opciones de depuración útiles para explicar ARKit (puntos de características)
        #if DEBUG
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        #endif

        context.coordinator.setupScene(in: sceneView, with: shapeType)
        context.coordinator.attachGestures(to: sceneView)

        // Iniciar sesión AR con configuración de rastreo 6DoF (ARWorldTrackingConfiguration)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.isLightEstimationEnabled = true
        configuration.environmentTexturing = .automatic

        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

        return sceneView
    }

    func updateUIView(_ uiView: ARSCNView, context: Context) {
        context.coordinator.updateAutoRotation(isAutoRotating)
    }

    static func dismantleUIView(_ uiView: ARSCNView, coordinator: Coordinator) {
        // Pausar la sesión de ARKit y la cámara al salir para liberar recursos de hardware
        uiView.session.pause()
        uiView.scene.rootNode.enumerateChildNodes { node, _ in
            node.removeFromParentNode()
        }
    }

    // MARK: - Coordinador para delegados y eventos de interacción
    final class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate, UIGestureRecognizerDelegate {
        var parent: ARViewContainer
        weak var sceneView: ARSCNView?

        // Contenedores de nodos
        var shapeContainerNode = SCNNode()
        var shapeNode: SCNNode?

        // Control de escala para el gesto de pellizco (pinch)
        private var currentScale: Float = 1.0

        init(_ parent: ARViewContainer) {
            self.parent = parent
            super.init()
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleResetNotification),
                name: .init("ResetARPosition"),
                object: nil
            )
        }

        deinit {
            NotificationCenter.default.removeObserver(self)
        }

        @objc private func handleResetNotification() {
            resetPosition()
        }

        func setupScene(in view: ARSCNView, with shape: ARShapeType) {
            self.sceneView = view
            let scene = SCNScene()
            view.scene = scene

            // Nodo contenedor principal colocado en el espacio 3D
            shapeContainerNode.name = "ShapeContainer"
            // Posicionamos inicialmente el objeto a 55 cm frente a la cámara a la altura de los ojos
            shapeContainerNode.position = SCNVector3(0, 0, -0.55)

            // Crear la figura seleccionada usando la fábrica
            let node = ARGeometryFactory.createNode(for: shape)
            self.shapeNode = node
            shapeContainerNode.addChildNode(node)

            // Iluminación omnidireccional ambiental complementaria
            let lightNode = SCNNode()
            lightNode.light = SCNLight()
            lightNode.light?.type = .omni
            lightNode.light?.intensity = 1000
            lightNode.position = SCNVector3(0, 0.4, 0.2)
            shapeContainerNode.addChildNode(lightNode)

            scene.rootNode.addChildNode(shapeContainerNode)

            // Aplicar rotación inicial si está activa
            if parent.isAutoRotating {
                node.runAction(ARGeometryFactory.createGentleRotationAction(), forKey: "autoRotation")
            }

            DispatchQueue.main.async {
                self.parent.trackingStatus = "Renderizando \(shape.title) en el espacio real"
            }
        }

        func updateAutoRotation(_ enabled: Bool) {
            guard let shapeNode = shapeNode else { return }
            if enabled {
                if shapeNode.action(forKey: "autoRotation") == nil {
                    shapeNode.runAction(ARGeometryFactory.createGentleRotationAction(), forKey: "autoRotation")
                }
            } else {
                shapeNode.removeAction(forKey: "autoRotation")
            }
        }

        func resetPosition() {
            guard let sceneView = sceneView else { return }
            // Reubica la figura justo enfrente de la posición actual de la cámara
            if let currentFrame = sceneView.session.currentFrame {
                var translation = matrix_identity_float4x4
                translation.columns.3.z = -0.50 // 50 cm hacia adelante

                let transform = simd_mul(currentFrame.camera.transform, translation)
                let newPosition = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)

                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                shapeContainerNode.position = newPosition
                shapeContainerNode.scale = SCNVector3(1, 1, 1)
                shapeContainerNode.eulerAngles = SCNVector3Zero
                currentScale = 1.0
                SCNTransaction.commit()

                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
        }

        // MARK: - Reconocedores de Gestos e Interacción
        func attachGestures(to view: ARSCNView) {
            // 1. Toque para rebotar / interactuar con la figura
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            view.addGestureRecognizer(tapGesture)

            // 2. Deslizar para rotar manualmente el objeto en 3D
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
            panGesture.delegate = self
            view.addGestureRecognizer(panGesture)

            // 3. Pellizcar para agrandar o encoger la figura
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
            pinchGesture.delegate = self
            view.addGestureRecognizer(pinchGesture)
        }

        @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let sceneView = sceneView else { return }
            let location = gesture.location(in: sceneView)

            let hitResults = sceneView.hitTest(location, options: [
                SCNHitTestOption.searchMode: SCNHitTestSearchMode.all.rawValue
            ])

            if let hit = hitResults.first(where: { $0.node == shapeNode || $0.node.name == "ARSelectedShapeNode" }) {
                // El usuario tocó directamente la figura 3D -> Salto y retroalimentación háptica
                let bounce = ARGeometryFactory.createBounceAction()
                hit.node.runAction(bounce)

                let feedback = UIImpactFeedbackGenerator(style: .heavy)
                feedback.impactOccurred()

                DispatchQueue.main.async {
                    self.parent.trackingStatus = "¡Interactuaste con \(self.parent.shapeType.title)!"
                }
            } else {
                // Toque en el espacio: reubicar la figura suavemente
                resetPosition()
            }
        }

        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let sceneView = sceneView else { return }
            let translation = gesture.translation(in: sceneView)

            let sensitivity: Float = 0.005
            let deltaY = Float(translation.x) * sensitivity
            let deltaX = Float(translation.y) * sensitivity

            shapeContainerNode.eulerAngles.y += deltaY
            shapeContainerNode.eulerAngles.x += deltaX

            gesture.setTranslation(.zero, in: sceneView)
        }

        @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            if gesture.state == .changed {
                let scaleChange = Float(gesture.scale)
                var newScale = currentScale * scaleChange

                // Límites de escala: entre 0.3x y 3.0x de su tamaño original
                newScale = max(0.3, min(newScale, 3.0))

                shapeContainerNode.scale = SCNVector3(newScale, newScale, newScale)
            } else if gesture.state == .ended {
                currentScale = shapeContainerNode.scale.x
            }
        }

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }

        // MARK: - ARSessionDelegate y ARSCNViewDelegate
        func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
            DispatchQueue.main.async {
                switch camera.trackingState {
                case .normal:
                    self.parent.trackingStatus = "ARKit: Seguimiento espacial activo"
                case .limited(let reason):
                    switch reason {
                    case .initializing:
                        self.parent.trackingStatus = "ARKit: Calibrando sensores de la cámara..."
                    case .excessiveMotion:
                        self.parent.trackingStatus = "ARKit: Movimiento muy rápido, ralentiza el dispositivo"
                    case .insufficientFeatures:
                        self.parent.trackingStatus = "ARKit: Poca textura o luz en el entorno"
                    case .relocalizing:
                        self.parent.trackingStatus = "ARKit: Reubicando mapa del entorno..."
                    @unknown default:
                        self.parent.trackingStatus = "ARKit: Calibrando..."
                    }
                case .notAvailable:
                    self.parent.trackingStatus = "ARKit: Seguimiento no disponible"
                }
            }
        }

        func session(_ session: ARSession, didFailWithError error: Error) {
            DispatchQueue.main.async {
                self.parent.trackingStatus = "Error de ARKit: \(error.localizedDescription)"
            }
        }
    }
}
