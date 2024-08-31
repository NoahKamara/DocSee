//
//  DebugMode.swift
//  DocSee
//
//  Created by Noah Kamara on 30.08.24.
//

import Foundation
import SwiftUI

@Observable
class DebugMode {
    public var isDebugging: Bool = true
}

extension EnvironmentValues {
    @Entry var debugMode: DebugMode = DebugMode()
}

struct DebugModeButton: View {
    @Environment(\.debugMode)
    private var debugMode: DebugMode

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
