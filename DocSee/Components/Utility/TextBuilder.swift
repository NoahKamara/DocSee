import SwiftUI

public extension Text {
    init(@TextBuilder builder: () -> Text) {
        self = builder()
    }
}

@resultBuilder
public struct TextBuilder {
    public static func buildBlock(_ forEach: ForEach<some Any, some Any, Text>) -> Text? {
        //        forEach.data.reduce(Text(""), { forEach.content($0) })
        if let first = forEach.data.first {
            forEach.data
                .dropFirst()
                .map(forEach.content)
                .reduce(forEach.content(first), buildPartialBlock)
        } else {
            Text("")
        }
    }

    public static func buildPartialBlock(first: Text) -> Text {
        first
    }

    public static func buildPartialBlock(accumulated: Text, next: Text) -> Text {
        accumulated + next
    }

    public static func buildEither(first component: Text) -> Text {
        component
    }

    public static func buildEither(second component: Text) -> Text {
        component
    }

    public static func buildOptional(_ component: Text?) -> Text {
        component ?? Text("")
    }
}
