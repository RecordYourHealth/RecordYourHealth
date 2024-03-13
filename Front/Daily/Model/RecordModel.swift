//
//  RecordModel.swift
//  Daily
//
//  Created by 최승용 on 3/13/24.
//

import Foundation

struct RecordModel: Codable {
    let uid: Int
    let goal_uid: Int
    let content: String
    let type: String
    let symbol: String
    let goal_time: Int
    let goal_count: Int
    let record_time: Int
    let record_count: Int
    let issuccess: Bool
    let start_time: String
}
