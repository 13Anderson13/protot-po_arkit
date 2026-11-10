//
//  ARCameraScreen.swift
//  Desarrollo_Arkit
//
//  Pantalla de cámara con Realidad Aumentada interactiva y controles.
//

import SwiftUI

struct ARCameraScreen: View {
    let shapeType: ARShapeType
    @Environment(\.dismiss) private var dismiss

    @State private var isAutoRotating: Bool = true
    @State private var trackingStatus: String = "Iniciando cámara y ARKit..."
    @State private var showingInfoSheet: Bool = false

    var body: some View {
        ZStack {
            // 1. Capa de Realidad Aumentada (Cámara + SceneKit)
            ARViewContainer(
                shapeType: shapeType,
                isAutoRotating: $isAutoRotating,
                trackingStatus: $trackingStatus
            )
            .edgesIgnoringSafeArea(.all)

            // 2. Capa de Controles y HUD superior e inferior
            VStack(spacing: 0) {
                // Barra superior
                topBar
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                // Indicador de estado de ARKit
                statusBanner
                    .padding(.top, 8)

                Spacer()

                // Panel de controles e interacciones inferior
                bottomControlPanel
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingInfoSheet) {
            ARInfoSheet(shapeType: shapeType)
        }
    }

    // MARK: - Barra Superior
    private var topBar: some View {
        HStack {
            // Botón Regresar
            Button(action: {
                dismiss()
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                    Text("Regresar")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
            }

            Spacer()

            // Distintivo de la Figura Seleccionada
            HStack(spacing: 8) {
                Image(systemName: shapeType.iconName)
                    .foregroundColor(shapeType.swiftUIColor)
                Text(shapeType.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)

            Spacer()

            // Botón de Información Educativa sobre ARKit
            Button(action: {
                showingInfoSheet = true
            }) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
            }
        }
    }

    // MARK: - Banner de Estado ARKit
    private var statusBanner: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color.green)
                .frame(width: 8, height: 8)
            Text(trackingStatus)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.65))
        .clipShape(Capsule())
        .animation(.easeInOut, value: trackingStatus)
    }

    // MARK: - Panel Inferior de Controles
    private var bottomControlPanel: some View {
        VStack(spacing: 12) {
            // Instrucción de interacción breve
            HStack(spacing: 6) {
                Image(systemName: "hand.tap.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
                Text("Toca la figura para interactuar • Desliza para rotar • Pellizca para escalar")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)

            // Fila de botones de acción
            HStack(spacing: 12) {
                // Botón de alternar rotación automática
                Button(action: {
                    withAnimation {
                        isAutoRotating.toggle()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isAutoRotating ? "pause.fill" : "play.fill")
                        Text(isAutoRotating ? "Pausar Giro" : "Girar Objeto")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isAutoRotating ? Color.blue.opacity(0.8) : Color.white.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                // Botón para resetear posición al centro frente a la cámara
                Button(action: {
                    // Notificar al coordinador para centrar
                    NotificationCenter.default.post(name: .init("ResetARPosition"), object: nil)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "camera.viewfinder")
                        Text("Reubicar")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Vista Modal Explicativa de ARKit
struct ARInfoSheet: View {
    let shapeType: ARShapeType
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Encabezado
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(shapeType.swiftUIColor.opacity(0.15))
                                .frame(width: 60, height: 60)
                            Image(systemName: shapeType.iconName)
                                .font(.system(size: 30))
                                .foregroundColor(shapeType.swiftUIColor)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(shapeType.title)
                                .font(.title2.bold())
                            Text(shapeType.subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom, 6)

                    Divider()

                    // Explicación de ARKit
                    VStack(alignment: .leading, spacing: 12) {
                        Label("¿Cómo funciona ARKit?", systemImage: "sparkles")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("ARKit utiliza la técnica de Odometría Visual Inercial (VIO). Esta técnica fusiona los datos de los sensores de movimiento del iPhone (acelerómetro y giroscopio) con el análisis fotograma a fotograma de la cámara para rastrear con alta precisión la posición tridimensional del dispositivo en el espacio físico real.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // Renderizado de la figura
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Renderizado de \(shapeType.title)", systemImage: "cube.transparent")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(shapeType.arExplanation)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    // Sistema de coordenadas
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Sistema de Coordenadas de ARKit", systemImage: "axis.3d")
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text("En ARKit, las coordenadas están en metros reales:\n• Eje X: Horizontal (positivo a la derecha)\n• Eje Y: Vertical (positivo hacia arriba)\n• Eje Z: Profundidad (negativo hacia el frente de la cámara)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer(minLength: 20)
                }
                .padding(20)
            }
            .navigationTitle("Explicación ARKit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cerrar") {
                        dismiss()
                    }
                    .font(.body.bold())
                }
            }
        }
    }
}

