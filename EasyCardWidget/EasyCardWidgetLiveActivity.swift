//
//  EasyCardWidgetLiveActivity.swift
//  EasyCardWidget
//
//  Created by Fred Z on 2025-02-21.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct EasyCardWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct EasyCardWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: EasyCardWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension EasyCardWidgetAttributes {
    fileprivate static var preview: EasyCardWidgetAttributes {
        EasyCardWidgetAttributes(name: "World")
    }
}

extension EasyCardWidgetAttributes.ContentState {
    fileprivate static var smiley: EasyCardWidgetAttributes.ContentState {
        EasyCardWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: EasyCardWidgetAttributes.ContentState {
         EasyCardWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: EasyCardWidgetAttributes.preview) {
   EasyCardWidgetLiveActivity()
} contentStates: {
    EasyCardWidgetAttributes.ContentState.smiley
    EasyCardWidgetAttributes.ContentState.starEyes
}
