//
//  GoalDateOrRepeatSetting.swift
//  Daily
//
//  Created by 최승용 on 2022/11/17.
//

import SwiftUI

struct GoalDateOrRepeatSetting: View {
    @StateObject var userInfo: UserInfo
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    var body: some View {
        Text("날짜 or 반복 설정")
            .font(.system(size: 20, weight: .bold))
        HStack {
            Picker("", selection: $userInfo.dateOrRepeat) {
                ForEach(["날짜", "반복"], id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            .padding(2)
            .cornerRadius(15)
        }
        .font(.system(size: 16))
        switch userInfo.dateOrRepeat {
        case "날짜":
//            MonthOnYear(userInfo: userInfo, month: Date().month, fontSize: 16, isTapSelect: true)
            Text("month calendar for date pick")
        case "반복":
//            WeekIndicator(userInfo: userInfo, tapPurpose: "select")
            Text("week indicator for date pick")
            DatePicker("시작일:", selection: $startDate, in: Date()..., displayedComponents: .date)
            DatePicker("종료일:", selection: $endDate, in: Date()..., displayedComponents: .date)
        default:
            Text("")
        }
    }
}
