//
//  ContentView.swift
//  Desarrollo_Arkit
//
//  Página inicial con menú de selección de figuras 3D para ARKit.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedShape: ARShapeType? = nil

    var body: some View {
        ZStack {
            // Fondo con gradiente sutil
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.11, blue: 0.18),
                    Color(red: 0.03, green: 0.04, blue: 0.07)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Encabezado Principal y Explicación de ARKit
                    headerView
                        .padding(.top, 16)

                    // Tarjeta explicativa de ARKit
                    arkitConceptCard

                    // Sección de Selección con los 3 Botones
                    VStack(alignment: .leading, spacing: 14) {
                        Text("SELECCIONA UNA FIGURA 3D")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 4)

                        // Botones: Esfera, Prisma y Cubo
                        ForEach(ARShapeType.allCases) { shape in
                            shapeSelectionButton(for: shape)
                        }
                    }

                    // Características del prototipo
                    featuresGrid

                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        // Apertura de la cámara en pantalla completa al seleccionar una figura
        .fullScreenCover(item: $selectedShape) { shape in
            ARCameraScreen(shapeType: shape)
        }
    }

    // MARK: - Encabezado
    private var headerView: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "arkit")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.cyan)
                Text("FRAMEWORK ARKIT")
                    .font(.system(size: 13, weight: .heavy, design: .monospaced))
                    .foregroundColor(.cyan)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.cyan.opacity(0.12))
            .clipShape(Capsule())

            Text("Prototipo de Realidad Aumentada")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)

            Text("Visualiza figuras geométricas 3D renderizadas en el espacio físico a través de la cámara del iPhone.")
                .font(.system(size: 15))
                .foregroundColor(.white.opacity(0.75))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }

    // MARK: - Tarjeta Conceptual de ARKit
    private var arkitConceptCard: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 44, height: 44)
                Image(systemName: "camera.metering.matrix")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("¿Cómo funciona este prototipo?")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)

                Text("ARKit fusiona los sensores de movimiento (IMU) y la cámara para rastrear el mundo en 6 grados de libertad (6DoF), anclando la figura 3D seleccionada exactamente donde apuntes.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(2)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Botón de Selección de Figura (Esfera, Prisma, Cubo)
    private func shapeSelectionButton(for shape: ARShapeType) -> some View {
        Button(action: {
            selectedShape = shape
        }) {
            HStack(spacing: 16) {
                // Contenedor del ícono 3D
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: shape.gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 58, height: 58)
                        .shadow(color: shape.swiftUIColor.opacity(0.5), radius: 8, x: 0, y: 4)

                    Image(systemName: shape.iconName)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(.white)
                }

                // Información textual
                VStack(alignment: .leading, spacing: 4) {
                    Text(shape.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(shape.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }

                Spacer()

                // Indicador de acción
                HStack(spacing: 4) {
                    Text("Abrir AR")
                        .font(.system(size: 13, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(shape.swiftUIColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(shape.swiftUIColor.opacity(0.15))
                .clipShape(Capsule())
            }
            .padding(14)
            .background(Color.white.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(shape.swiftUIColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    // MARK: - Grid de Funcionalidades
    private var featuresGrid: some View {
        VStack(spacing: 10) {
            featureRow(icon: "arrow.triangle.2.circlepath", title: "Rotación e Interacción", subtitle: "Giro automático suave, arrastre manual y salto al tocar")
            featureRow(icon: "arrow.up.left.and.arrow.down.right", title: "Escalado con Pellizco", subtitle: "Agranda o reduce las figuras con tus dedos")
            featureRow(icon: "arrow.uturn.backward.circle.fill", title: "Navegación Fluida", subtitle: "Regresa en cualquier momento para proyectar otra figura")
        }
        .padding(.top, 8)
    }

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(.cyan)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.55))
            }

            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Efecto de pulsación animada para botones
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}
