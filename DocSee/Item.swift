//
//  Item.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

import SwiftUI

struct TestView: View {
    var body: some View {
        Text("")
            .onAppear {
                print(Bundle.allBundles)
            }
    }
}

#Preview {
    TestView()
}
