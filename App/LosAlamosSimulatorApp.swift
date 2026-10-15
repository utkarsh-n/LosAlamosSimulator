import SwiftUI

@main
struct LosAlamosSimulatorApp: App {
    var body: some Scene {
        WindowGroup {
            LosAlamosRootView()
                .preferredColorScheme(.dark)
                .tint(MetroTheme.cyan)
        }
    }
}

struct LosAlamosRootView: View {
    @State private var tab = LaunchOptions.lab

    var body: some View {
        TabView(selection: $tab) {
            Tab("Trinity", systemImage: "sun.horizon", value: 0) {
                shell { TrinityView(isSelected: tab == 0) }
            }
            Tab("Fission", systemImage: "atom", value: 1) {
                shell { AtomLabView() }
            }
            Tab("Chain", systemImage: "point.3.connected.trianglepath.dotted", value: 2) {
                shell { ChainReactionView(isSelected: tab == 2) }
            }
            Tab("Field Notes", systemImage: "book.closed", value: 3) {
                shell { FieldGuideView() }
            }
        }
    }

    private func shell<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        NavigationStack {
            ZStack {
                MetroBackground()
                content()
            }
            .navigationTitle("Los Alamos Simulator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MetroTheme.background, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Read field notes", systemImage: "info.circle") { tab = 3 }
                        .labelStyle(.iconOnly)
                        .accessibilityIdentifier("fieldNotesButton")
                }
            }
        }
    }
}

enum LaunchOptions {
    static var lab: Int { Int(value("lab") ?? "0").flatMap { (0...3).contains($0) ? $0 : nil } ?? 0 }
    static var time: Double { Double(value("time") ?? "0") ?? 0 }
    static var generation: Int { Int(value("generation") ?? "0") ?? 0 }
    static var factor: Double { Double(value("k") ?? "1.2") ?? 1.2 }

    private static func value(_ key: String) -> String? {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("--\(key)=") })?
            .dropFirst(key.count + 3).description
        #else
        return nil
        #endif
    }
}
