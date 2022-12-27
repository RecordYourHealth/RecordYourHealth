//
//  Calendar_Year.swift
//  Daily
//
//  Created by 최승용 on 2022/11/06.
//

import SwiftUI

struct Calendar_Year: View {
    @StateObject var userInfo: UserInfo
    var body: some View {
        VStack(spacing: 0) {
            CustomDivider(color: .black, height: 2)
                .padding(12)
            ForEach (0..<4) { rowIndex in
                HStack(spacing: 0) {
                    ForEach (0..<3) { colIndex in
                        let month = (rowIndex * 3) + colIndex + 1
                        Button {
                            withAnimation {
                                userInfo.currentMonth = month
                                userInfo.currentState = "month"
                            }
                        } label: {
                            MonthOnYear(userInfo: userInfo, month: month)
                                .accentColor(.black)
                        }
                    }
                }
            }
            Spacer()
        }
        .onAppear {
            getCalendarYear(userID: "2", year: String(userInfo.currentYear)) { (success, data) in
                print(data)
            }
            print("calendar year appear")
            print(userInfo.currentYear)
        }
        .onChange(of: userInfo.currentYear) { year in
            getCalendarYear(userID: String(userInfo.uid), year: String(year)) { (success, data) in
                print(data)
            }
            print("calendar year change")
            print(year)
        }
    }
}
