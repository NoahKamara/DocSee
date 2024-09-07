//
//  AppSettings.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import SwiftUI

@Observable
class DebugMode {
    public var isDebugging: Bool = true
}

extension EnvironmentValues {
    @Entry var debugMode: DebugMode = .init()
}

struct DebugModeButton: View {
    @Environment(\.debugMode)
    private var debugMode

    public init() {}

    var body: some View {
        @Bindable var debugMode = debugMode

        Toggle(isOn: $debugMode.isDebugging) {
            Image(systemName: "ant")
        }
        .toggleStyle(.button)
    }
}

#Preview {
    DebugModeButton()
}
