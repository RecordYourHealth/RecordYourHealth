//
//  DailyRecordList.swift
//  Daily
//
//  Created by seungyooooong on 11/29/24.
//

import SwiftUI
import SwiftData

// MARK: - DailyRecordList
struct DailyRecordList: View {
    let date: Date
    let records: [DailyRecordModel]
    
    init(date: Date, records: [DailyRecordModel]) {
        self.date = date
        self.records = records.sorted {
            if let prevGoal = $0.goal, let nextGoal = $1.goal, prevGoal.isSetTime != nextGoal.isSetTime {
                return !prevGoal.isSetTime && nextGoal.isSetTime
            }
            if let prevGoal = $0.goal, let nextGoal = $1.goal, prevGoal.setTime != nextGoal.setTime {
                return prevGoal.setTime < nextGoal.setTime
            }
            return $0.date < $1.date
        }
    }
    
    var body: some View {
        VStack {
            let processedRecords = records.reduce(into: [(record: DailyRecordModel, showTimeline: Bool)]()) { result, record in
                let prevGoal = result.last?.record.goal
                let showTimeline = record.goal.map { goal in
                    if goal.isSetTime { return prevGoal.map { !$0.isSetTime || $0.setTime != goal.setTime } ?? true }
                    return false
                } ?? false
                result.append((record, showTimeline))
            }
            ForEach(processedRecords, id: \.record.id) { processed in
                let record = processed.record
                if let goal = record.goal {
                    if processed.showTimeline { DailyTimeLine(setTime: goal.setTime) }
                    DailyRecord(record: record)
                        .contextMenu { DailyMenu(record: record, date: date) }
                }
            }
        }
    }
}

// MARK: - DailyMenu
struct DailyMenu: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var navigationEnvironment: NavigationEnvironment
    let record: DailyRecordModel
    let date: Date
    
    init(record: DailyRecordModel, date: Date) {
        self.record = record
        self.date = date
    }

    var body: some View {
        if let goal = record.goal {
            VStack {
                // MARK: ModifyGoal
                if goal.cycleType == .date || goal.parentGoal != nil {
                    Button {
                        let data = ModifyDataModel(date: date, modifyRecord: record, modifyType: .record)
                        let navigationObject = NavigationObject(viewType: .modify, data: data)
                        navigationEnvironment.navigate(navigationObject)
                    } label: {
                        Label("목표 수정", systemImage: "pencil.line")
                    }
                } else {
                    Menu {
                        Button {
                            let data = ModifyDataModel(date: date, modifyRecord: record, modifyType: .single)
                            let navigationObject = NavigationObject(viewType: .modify, data: data)
                            navigationEnvironment.navigate(navigationObject)
                        } label: {
                            Text("단일 수정")
                        }
                        Button {
                            let data = ModifyDataModel(date: date, modifyRecord: record, modifyType: .all)
                            let navigationObject = NavigationObject(viewType: .modify, data: data)
                            navigationEnvironment.navigate(navigationObject)
                        } label: {
                            Text("일괄 수정")
                        }
                    } label: {
                        Label("목표 수정", systemImage: "pencil.line")
                    }
                }
                // MARK: DeleteGoal
                if goal.cycleType == .date {
                    Button {
                        modelContext.delete(goal)
                        try? modelContext.save()
                    } label: {
                        Label("목표 삭제", systemImage: "trash")
                    }
                } else {
                    Menu {
                        Button {
                            modelContext.delete(record)
                            try? modelContext.save()
                        } label: {
                            Text("단일 삭제")
                        }
                        Menu {
                            Button {
                                guard let totalRecords = try? modelContext.fetch(FetchDescriptor<DailyRecordModel>()) else { return }
                                let deleteRecords = totalRecords.filter { currentRecord in
                                    guard let currentGoal = currentRecord.goal else { return false }
                                    return currentGoal.parentGoal?.id ?? currentGoal.id == goal.id && currentRecord.date >= Date().startOfDay()
                                }
                                deleteRecords.forEach { modelContext.delete($0) }
                                try? modelContext.save()
                            } label: {
                                Text("오늘 이후의 목표만 삭제")
                            }
                            Button {
                                goal.childGoals.forEach { modelContext.delete($0) }
                                modelContext.delete(goal)
                                try? modelContext.save()
                            } label: {
                                Text("과거의 기록도 함께 삭제")
                            }
                        } label: {
                            Text("일괄 삭제")
                        }
                    } label: {
                        Label("목표 삭제", systemImage: "trash")
                    }
                }
            }
        }
    }
}

// MARK: - DailyRecord
struct DailyRecord: View {
    let record: DailyRecordModel
    let isButtonDisabled: Bool
    
    init(record: DailyRecordModel, isButtonDisabled: Bool = false) {
        self.record = record
        self.isButtonDisabled = isButtonDisabled
    }
    
    var body: some View {
        if let goal = record.goal {
            HStack(spacing: 12) {
                Image(systemName: "\(goal.symbol.imageName)\(record.isSuccess ? ".fill" : "")")
                Text(goal.content)
                Spacer()
                DailyRecordButton(record: record, color: isButtonDisabled ? Colors.reverse : Colors.daily)
                    .frame(maxHeight: 40)
                    .disabled(isButtonDisabled)
            }
            .frame(height: 60)
            .overlay {
                let recordCount = goal.type == .timer ? record.count.timerFormat() : String(record.count)
                let goalCount = goal.type == .timer ? goal.count.timerFormat() : String(goal.count)
                Text("\(recordCount) / \(goalCount)")
                    .font(.system(size : CGFloat.fontSize * 2))
                    .padding(.top, CGFloat.fontSize)
                    .padding(.trailing, 40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
            .padding(.horizontal, CGFloat.fontSize * 2)
            .foregroundStyle(Colors.reverse)
            .background {
                RoundedRectangle(cornerRadius: 15).fill(Colors.background)
            }
            .padding(.horizontal, CGFloat.fontSize / 2)
        }
    }
}

// MARK: - DailyNoRecord
struct DailyNoRecord: View {
    @EnvironmentObject var navigationEnvironment: NavigationEnvironment
    @EnvironmentObject var dailyCalendarViewModel: DailyCalendarViewModel
    
    var body: some View {
        VStack {
            Text(noRecordText)
            Button {
                let data = GoalDataModel(date: dailyCalendarViewModel.currentDate)
                let navigationObject = NavigationObject(viewType: .goal, data: data)
                navigationEnvironment.navigate(navigationObject)
            } label: {
                Text(goRecordViewText)
                    .foregroundStyle(Colors.daily)
            }
        }
        .padding()
        .padding(.bottom, CGFloat.screenHeight * 0.25)
        .font(.system(size: CGFloat.fontSize * 2.5, weight: .bold))
    }
}
