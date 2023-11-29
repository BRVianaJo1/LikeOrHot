//
//  VideoViewModel.swift
//  likeOrHot
//
//  Created by Joao on 28/11/23.
//

import Foundation
import AVFoundation

class VideoViewModel: ObservableObject{
    @Published var dataVideo = [Look]()
    
    init(){
        loadData()
    }
    
    func loadData()  {
        guard let file = Bundle.main.url(forResource: "datalikeOrHot", withExtension: "json")
            else {
                print("Json file not found")
                return
            }
        
        guard let data = try? Data(contentsOf: file)
        else {
            print("Error with data")
            return
        }
        guard let looks = try? JSONDecoder().decode([Look].self, from: data)
        else {
            print("Error decoder")
            return
            
        }
        self.dataVideo = looks
    }
    
    func populateArrayVideo() -> [Video] {
        var data = [Video]()
        for videoData in dataVideo {
            guard let urlVideo = URL(string: videoData.compressedForIosURL) else { return data}
            data.append(Video(id: videoData.id, player:  AVPlayer(url: urlVideo), userPicture: videoData.profilePictureURL, body: videoData.body, likereaction: 0, hotReaction: 0))
        }
        return data
    }
}

