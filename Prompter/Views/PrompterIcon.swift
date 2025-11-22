import SwiftUI

struct PrompterIcon: View {
    var size: CGFloat = 18

    var body: some View {
        ZStack {
            // Background card stack (represents multiple prompts)
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.9, height: size * 0.7)
                .offset(x: size * 0.05, y: size * 0.1)

            // Front card
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(
                    LinearGradient(
                        colors: [Color.blue, Color.cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.9, height: size * 0.7)
                .overlay(
                    // Text lines (prompt content)
                    VStack(spacing: size * 0.08) {
                        RoundedRectangle(cornerRadius: size * 0.03)
                            .fill(Color.white.opacity(0.9))
                            .frame(width: size * 0.6, height: size * 0.06)

                        RoundedRectangle(cornerRadius: size * 0.03)
                            .fill(Color.white.opacity(0.7))
                            .frame(width: size * 0.5, height: size * 0.06)
                    }
                )

            // AI sparkle (top right corner)
            Image(systemName: "sparkles")
                .font(.system(size: size * 0.35, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .offset(x: size * 0.35, y: -size * 0.35)
                .shadow(color: .yellow.opacity(0.5), radius: size * 0.1)
        }
        .frame(width: size, height: size)
    }
}

// Alternative: Simple text-based icon
struct PrompterIconSimple: View {
    var size: CGFloat = 18

    var body: some View {
        ZStack {
            // Rounded square background
            RoundedRectangle(cornerRadius: size * 0.25)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.2, green: 0.5, blue: 1.0), Color(red: 0.4, green: 0.3, blue: 0.9)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            // "P" letter
            Text("P")
                .font(.system(size: size * 0.65, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
    }
}

// Alternative: Card stack with AI element
struct PrompterIconMinimal: View {
    var size: CGFloat = 18

    var body: some View {
        ZStack {
            // Stack of cards
            ForEach(0..<3) { i in
                RoundedRectangle(cornerRadius: size * 0.15)
                    .fill(Color.blue.opacity(1.0 - Double(i) * 0.2))
                    .frame(width: size * 0.7, height: size * 0.5)
                    .offset(x: -CGFloat(i) * size * 0.08, y: CGFloat(i) * size * 0.08)
            }

            // AI sparkle overlay
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.white, Color.yellow.opacity(0)],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.15
                    )
                )
                .frame(width: size * 0.3, height: size * 0.3)
                .offset(x: size * 0.25, y: -size * 0.25)
        }
    }
}

#Preview("All Icons") {
    HStack(spacing: 30) {
        VStack {
            PrompterIcon(size: 32)
            Text("Gradient")
                .font(.caption)
        }

        VStack {
            PrompterIconSimple(size: 32)
            Text("Simple")
                .font(.caption)
        }

        VStack {
            PrompterIconMinimal(size: 32)
            Text("Minimal")
                .font(.caption)
        }

        VStack {
            Image(systemName: "text.bubble")
                .font(.system(size: 32))
            Text("Current")
                .font(.caption)
        }
    }
    .padding()
}
