//
//  DailyWidget.swift
//  DailyWidget
//
//  Created by 최승용 on 5/8/24.
//

import WidgetKit
import SwiftUI
import SwiftData
import DailyUtilities

struct Provider: TimelineProvider {
    let dailyModelContainer: ModelContainer
    
    init() {
        dailyModelContainer = try! ModelContainer(
            for: DailyGoalModel.self, DailyRecordModel.self,
            configurations: ModelConfiguration(url: FileManager.sharedContainerURL())
        )
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), rating: 0, day: String(Calendar.current.component(.day, from: Date())), records: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), rating: 0, day: String(Calendar.current.component(.day, from: Date())), records: [])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let context = ModelContext(dailyModelContainer)
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let descriptor = FetchDescriptor<DailyRecordModel>(
            predicate: #Predicate<DailyRecordModel> { record in
                today <= record.date && record.date < tomorrow
            }
        )
        
        guard let recordsQuery = try? context.fetch(descriptor) else { return }
        let records = recordsQuery.sorted {
            if let prevGoal = $0.goal, let nextGoal = $1.goal, prevGoal.isSetTime != nextGoal.isSetTime {
                return !prevGoal.isSetTime && nextGoal.isSetTime
            }
            if let prevGoal = $0.goal, let nextGoal = $1.goal, prevGoal.setTime != nextGoal.setTime {
                return prevGoal.setTime < nextGoal.setTime
            }
            if $0.isSuccess != $1.isSuccess {
                return !$0.isSuccess && $1.isSuccess
            }
            return $0.date < $1.date
        }
        let simpleRecords = records.map { SimpleRecordModel(record: $0) }
        let rating = records.isEmpty ? 0.0 : Double(records.filter { $0.isSuccess }.count) / Double(records.count)
        
        var entries: [SimpleEntry] = []
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: Date())!
            let entry = SimpleEntry(
                date: entryDate,
                rating: rating,
                day: String(Calendar.current.component(.day, from: Date())),
                records: simpleRecords
            )
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleRecordModel: Codable {
    let content: String
    let symbol: Symbols
    let isSuccess: Bool
    let isSetTime: Bool
    let setTime: String
    
    init(isEmpty: Bool = true) {
        self.content = ""
        self.symbol = .check
        self.isSuccess = false
        self.isSetTime = false
        self.setTime = "00:00"
    }
    
    init(record: DailyRecordModel) {
        self.content = record.goal?.content ?? ""
        self.symbol = record.goal?.symbol ?? .check
        self.isSuccess = record.isSuccess
        self.isSetTime = record.goal?.isSetTime ?? false
        self.setTime = record.goal?.setTime ?? "00:00"
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let rating: Double
    let day: String
    let records: [SimpleRecordModel]
}

struct DailyWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            VStack(alignment: .leading) {
                SimpleDayRating(day: entry.day, rating: entry.rating)
                SymbolListInSmallWidget(records: entry.records)
            }
            .font(.system(size: CGFloat.fontSize))
        default:
            HStack(alignment: .top) {
                SimpleDayRating(day: entry.day, rating: entry.rating)
                SimpleRecordList(records: entry.records)
            }
            .font(.system(size: CGFloat.fontSize))
        }
    }
}

struct SimpleDayRating: View {
    @State var day: String
    @State var rating: Double
    
    var body: some View {
        ZStack {
            Image(systemName: "circle.fill")
                .font(.system(size: CGFloat.fontSize * 2))
                .foregroundColor(Colors.daily.opacity(rating * 0.8))
            Text(day)
                .font(.system(size: CGFloat.fontSize, weight: .bold))
                .foregroundColor(.primary)
        }
    }
}

struct SymbolListInSmallWidget: View {
    @State var records: [SimpleRecordModel]
    
    var body: some View {
        Group {
            if records.count > 0 {
                VStack {
                    ForEach(0 ..< 2) { rowIndex in
                        HStack {
                            ForEach(0 ..< 3) { colIndex in
                                let index = rowIndex * 3 + colIndex
                                let record = index < records.count ? records[index] : SimpleRecordModel(isEmpty: true)
                                Image(systemName: "\(record.symbol.imageName)\(record.isSuccess ? ".fill" : "")")
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .opacity(index < records.count ? 1 : 0)
                            }
                        }
                    }
                }
            } else { SimpleText() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 15).fill(Colors.background)
        }
    }
}

struct SimpleRecordList: View {
    @Environment(\.widgetFamily) private var family
    @State var records: [SimpleRecordModel]
    
    var body: some View {
        VStack {
            if records.count > 0 {
                ForEach(records.indices, id: \.self) { index in
                    switch family {
                    case .systemMedium:
                        if index < 3 {
                            SimpleRecordOnList(record: records[index])
                        }
                    default:
                        if index < 7 {
                            SimpleRecordOnList(record: records[index])
                        }
                    }
                }
                Spacer()
            } else {
                SimpleText()
                    .background {
                        RoundedRectangle(cornerRadius: 15).fill(Colors.background)
                    }
            }
        }
    }
}

struct SimpleRecordOnList: View {
    @State var record: SimpleRecordModel
    
    var body: some View {
        ZStack {
            HStack(spacing: 12) {
                Image(systemName: "\(record.symbol.imageName)\(record.isSuccess ? ".fill" : "")")
                Text(record.content)
                    .lineLimit(1)
                Spacer()
                if record.isSetTime { Text(record.setTime) }
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 15).fill(Colors.background)
        }
    }
}

struct SimpleText: View {
    @Environment(\.widgetFamily) private var family
    
    var body: some View {
        VStack {
            Text("아직 목표가 없어요 😓")
            if family != .systemSmall {
                Text("목표 세우러 가기")
                    .foregroundColor(Colors.daily)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(CGFloat.fontSize < 15 ? 0 : 10)
    }
}

struct DailyWidget: Widget {
    let kind: String = "DailyWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DailyWidgetEntryView(entry: entry)
                .containerBackground(Colors.theme, for: .widget)
                .widgetURL(URL(string: "widget://daily")!)
        }
        .configurationDisplayName("Daily Widget")
        .description("위젯으로 더욱 간편하게! :D")
    }
}

extension CGFloat {
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    
    static let fontSizeForiPhone15 = 15 * screenWidth / 393 // 6.7 iPhone 기준
    static let fontSize = UIDevice.current.model == "iPhone" ? fontSizeForiPhone15 : fontSizeForiPhone15 / 2
}
