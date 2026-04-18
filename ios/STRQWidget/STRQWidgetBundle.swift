import WidgetKit
import SwiftUI

@main
struct STRQWidgetBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        StreakWidget()
    }
}
