//
//  BackgroundDecorations.swift
//  Moment
//
//  背景装饰组件 - 浮动云朵效果
//

import SwiftUI

struct BackgroundDecorations: View {
    @State private var blob1Offset: CGSize = .zero
    @State private var blob2Offset: CGSize = .zero

    var body: some View {
        ZStack {
            // Blob 1
            BlobShape()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "a78bfa"), Color(hex: "f5a5d1")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 300, height: 300)
                .scaleEffect(0.8)
                .offset(x: 120, y: -80)
                .blur(radius: 60)
                .opacity(0.08)
                .animation(
                    Animation.easeInOut(duration: 6).repeatForever(autoreverses: true),
                    value: blob1Offset
                )

            // Blob 2
            BlobShape()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "a7e4d0"), Color(hex: "a8d8ea")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 250, height: 250)
                .scaleEffect(0.7)
                .offset(x: -80, y: 100)
                .blur(radius: 50)
                .opacity(0.08)
                .animation(
                    Animation.easeInOut(duration: 8).repeatForever(autoreverses: true),
                    value: blob2Offset
                )
        }
    }
}

struct BlobShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint(x: width * 0.4, y: height * 0.4))
        path.addCurve(
            to: CGPoint(x: width * 0.6, y: height * 0.5),
            control1: CGPoint(x: width * 0.7, y: height * 0.3),
            control2: CGPoint(x: width * 0.8, y: height * 0.5)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.6),
            control1: CGPoint(x: width * 0.7, y: height * 0.7),
            control2: CGPoint(x: width * 0.4, y: height * 0.7)
        )
        path.addCurve(
            to: CGPoint(x: width * 0.4, y: height * 0.4),
            control1: CGPoint(x: width * 0.3, y: height * 0.5),
            control2: CGPoint(x: width * 0.2, y: height * 0.4)
        )

        return path
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    BackgroundDecorations()
        .background(Color(hex: "faf8f6"))
}