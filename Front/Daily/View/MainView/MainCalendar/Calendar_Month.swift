//
//  Calendar_Month.swift
//  Daily
//
//  Created by 최승용 on 2022/11/06.
//

import SwiftUI

struct Calendar_Month: View {
    @StateObject var calendar: MyCalendar
    var body: some View {
        VStack {
            WeekIndicator()
            CustomDivider(color: .black, height: 2, hPadding: 12)
            VStack {
                ForEach (0..<6) { rowIndex in
                    WeekOnMonth(calendar: calendar, rowIndex: rowIndex)
                    if rowIndex < 5 { CustomDivider(hPadding: 20) }
                }
                Spacer()
            }
            
            NavigationLink(
                destination: Calendar_Week_Day()
                    .navigationBarTitle(Date().getDay),
                isActive: $calendar.showWeekDay,
                label: { EmptyView() }
            )
        }
        .onAppear {
            calendar.setState(state: "Month")
        }
    }
}
