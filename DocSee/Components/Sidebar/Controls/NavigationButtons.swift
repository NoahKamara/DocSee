//
//  NavigationButtons.swift
// DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import SwiftUI

struct NavigationButtons: View {
    @Bindable var navigator: Navigator

    var body: some View {
        ControlGroup {
            Menu {
                ForEach(Array(navigator.history.pastItems.enumerated()), id: \.offset) { item in
                    Button(action: { navigator.goBack(1 + item.offset) }) {
                        Text(item.element.url.absoluteString)
                    }
                }
            } label: {
                Image(systemName: "chevron.backward")
            } primaryAction: {
                navigator.goBack()
            }
            .disabled(!navigator.canGoBack)

            Menu {
                ForEach(Array(navigator.history.futureItems.enumerated()), id: \.offset) { item in
                    Button(action: { navigator.goForward(1 + item.offset) }) {
                        Text(item.element.url.absoluteString)
                    }
                }
            } label: {
                Image(systemName: "chevron.forward")
            } primaryAction: {
                navigator.goForward()
            }
            .disabled(!navigator.canGoForward)
        }
        .controlGroupStyle(.navigation)
        .menuIndicator(.hidden)
#if os(macOS)
            .menuStyle(.borderedButton)
#else
            .menuStyle(.borderlessButton)
#endif
    }
}
