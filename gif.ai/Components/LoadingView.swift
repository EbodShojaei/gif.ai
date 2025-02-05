import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    @State private var pulsate = false
    
    var body: some View {
        ZStack {
            // Frosted glass background
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .frame(width: 100, height: 100)
                .scaleEffect(pulsate ? 1.1 : 1.0)
                .opacity(pulsate ? 0.8 : 0.6)
            
            // Spinning circle
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [.blue, .purple]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 1)
                    .repeatForever(autoreverses: false),
                    value: isAnimating
                )
            
            // Optional: Add a subtle glow effect
            Circle()
                .fill(Color.accentColor.opacity(0.3))
                .frame(width: 40, height: 40)
                .blur(radius: 10)
                .opacity(pulsate ? 0.6 : 0.3)
        }
        .onAppear {
            isAnimating = true
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                pulsate = true
            }
        }
    }
}

// For use in dark backgrounds
struct DarkBackgroundLoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .edgesIgnoringSafeArea(.all)
            LoadingView()
        }
    }
}

#Preview {
    Group {
        LoadingView()
            .preferredColorScheme(.light)
        
        LoadingView()
            .preferredColorScheme(.dark)
            .background(Color.gray)
        
        DarkBackgroundLoadingView()
    }
}
