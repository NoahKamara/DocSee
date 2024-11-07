//
//  Navigator.swift
//  DocSee
//
//  Copyright © 2024 Noah Kamara.
//

import Docsy
import Observation

@Observable
@MainActor
public class Navigator {
    var selection: TopicReference?

    public func goto(_ reference: TopicReference) {
        withMutation(keyPath: \.selection) {
            self.selection = reference
        }
    }

    init(
        initialTopic: TopicReference? = nil
    ) {
        self.selection = initialTopic
    }
}
