//
//  Calendar_Year.swift
//  Daily
//
//  Created by 최승용 on 2022/11/06.
//

import SwiftUI

struct Calendar_Year: View {
    @StateObject var calendar: Calendar
    var body: some View {
        VStack(spacing: 0) {
            CustomDivider(color: .black, height: 2)
                .padding(12)
            ForEach (0..<4) { rowIndex in
                HStack(spacing: 0) {
                    ForEach (0..<3) { colIndex in
                        let monthIndex = (rowIndex * 3) + colIndex
                        NavigationLink {
                            Calendar_Month(calendar: calendar)
                                .navigationBarTitle(Mformat.string(from: Date()))
                        } label: {
                            MonthOnYear(calendar: calendar, monthIndex: monthIndex)
                                .accentColor(.black)
                        }
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
