//
//  videoModel.swift
//  likeOrHot
//
//  Created by Joao on 28/11/23.
//

import Foundation
import AVKit

// MARK: - Look
struct Look: Codable, Identifiable {
    let id: Int
    let songURL: String
    let body: String
    let profilePictureURL: String
    let username: String
    let compressedForIosURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case songURL = "song_url"
        case body
        case profilePictureURL = "profile_picture_url"
        case username
        case compressedForIosURL = "compressed_for_ios_url"
    }
}

struct Video : Identifiable {
    
    var id : Int
    var player : AVPlayer
    var userPicture: String
    var body : String
    var likereaction : Int
    var hotReaction : Int
}
