import SwiftUI
import WidgetKit

@main
struct StreakWidgets: WidgetBundle {
  var body: some Widget {
    HabitGridWidget()
    TodayWidget()
    StatsWidget()
    TodosWidget()
    HeatmapWidget()
  }
}

struct HabitTrackerEntry: TimelineEntry {
  let date: Date
  let payload: Payload?
}

enum Timelines {
  static func dates() -> [Date] {
    let now = Date()
    let cutoff = Payload.load(at: now)?.dayCutoff ?? 0
    return [now, DayKeys.nextDayStart(after: now, cutoff: cutoff)]
  }
}

struct HabitTrackerProvider: TimelineProvider {
  func placeholder(in context: Context) -> HabitTrackerEntry {
    HabitTrackerEntry(date: Date(), payload: nil)
  }

  func getSnapshot(in context: Context, completion: @escaping (HabitTrackerEntry) -> Void) {
    completion(HabitTrackerEntry(date: Date(), payload: Payload.load()))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<HabitTrackerEntry>) -> Void) {
    let dates = Timelines.dates()
    let entries = dates.map { HabitTrackerEntry(date: $0, payload: Payload.load(at: $0)) }
    completion(Timeline(entries: entries, policy: .after(dates[1])))
  }
}
