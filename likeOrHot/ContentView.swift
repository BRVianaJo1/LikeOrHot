//
//  ContentView.swift
//  likeOrHot
//
//  Created by Joao on 28/11/23.
//

import SwiftUI
import AVKit

struct ContentView: View {
var body: some View {
    Home()
}
}

struct ContentView_Previews: PreviewProvider {
static var previews: some View {
    ContentView()
}
}

struct Home : View {

@State var index = 0
@State var top = 0
@State var data = VideoViewModel().populateArrayVideo()

var body: some View{

    ZStack{

        PlayerScrollView(data: self.$data)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .edgesIgnoringSafeArea(.all)
    }
}
}

struct PlayerView : View {

@Binding var data : [Video]

var body: some View{

    VStack(spacing: 0){
      
        List(0..<self.data.count){i in
                
                ZStack{
                    Player(player: self.data[i].player)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .swipeActions(edge:  .leading) {
                            Button(action: {
                                self.data[i].likereaction+=1
                            }) {
                                Image(systemName: "heart.fill")
                                    .resizable()
                                    .frame(width: 60, height: 60)
                            }
                        }
                        .swipeActions(edge:  .trailing) {
                            Button(action: {
                                self.data[i].hotReaction+=1
                            }) {
                                Image(systemName: "flame")
                                    .resizable()
                                    .foregroundColor(.red)
                                    .frame(width: 60, height: 60)
                            }
                            .tint(.red)
                        }
                    
                    VStack(alignment: .leading) {
                        HStack(spacing: 10){
                            AsyncImage(url: URL(string: self.data[i].userPicture)) { phase in
                                switch phase {
                                case .empty:
                                    Image(systemName: "photo")
                                        .frame(width: 60, height: 60)
                                case .success(let image):
                                    image.resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 60, maxHeight: 60)
                                case .failure:
                                    Image(systemName: "photo")
                                        .frame(width: 60, height: 60)
                                @unknown default:
                                    EmptyView()
                                        .frame(width: 60, height: 60)
                                }
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            
                            Text(self.data[i].body)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                                .padding(.top)
                            Spacer()
                        }
                        .background(Color.clear)
                        .offset( x: 20, y: 40)
                        
                        Spacer()
                        
                        HStack(){
                                VStack(){
                                    Image(systemName: "heart.fill")
                                        .renderingMode(.original)
                                        .resizable()
                                        .frame(width: 60, height: 60)
                                        .onTapGesture {
                                            self.data[i].likereaction+=1
                                        }
                                    
                                    Text(String(self.data[i].likereaction))
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                    
                                }
                            .offset( x: 20)
                            Spacer()
                            
                                VStack(){
                                    Image(systemName: "flame")
                                        .resizable()
                                        .foregroundColor(.red)
                                        .frame(width: 60, height: 60)
                                        .onTapGesture {
                                            self.data[i].hotReaction+=1
                                        }
                                    
                                    Text(String(self.data[i].hotReaction))
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                }
                            .offset( x: -20)
                        }
                        
                        Spacer()
                    }
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    
                }
                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                .listRowSeparator(.hidden)
            }
        .frame( maxWidth: .infinity, maxHeight: .infinity)
            .edgesIgnoringSafeArea(.all)
            .listStyle(.plain)
    }
    .onAppear {
        
        self.data[0].player.play()
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { _ in
            self.data[0].player.seek(to: .zero)
            self.data[0].player.play()
        }
    }
}
}

struct Player : UIViewControllerRepresentable {

var player : AVPlayer

func makeUIViewController(context: Context) -> AVPlayerViewController{

    let view = AVPlayerViewController()
    view.player = player
    view.showsPlaybackControls = false
    view.videoGravity = .resizeAspectFill
    return view
}

func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {


}
}

class Host : UIHostingController<ContentView>{

override var preferredStatusBarStyle: UIStatusBarStyle{

    return .lightContent
}
}

struct PlayerScrollView : UIViewRepresentable {


func makeCoordinator() -> Coordinator {

    return PlayerScrollView.Coordinator(parent1: self)
}

@Binding var data : [Video]

func makeUIView(context: Context) -> UIScrollView{

    let view = UIScrollView()

    let childView = UIHostingController(rootView: PlayerView(data: self.$data))


    childView.view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * CGFloat((data.count)))

    view.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * CGFloat((data.count)))

    view.addSubview(childView.view)
    view.showsVerticalScrollIndicator = false
    view.showsHorizontalScrollIndicator = false

    view.contentInsetAdjustmentBehavior = .never
    view.isPagingEnabled = true
    view.delegate = context.coordinator

    return view
}

func updateUIView(_ uiView: UIScrollView, context: Context) {

    uiView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * CGFloat((data.count)))

    for i in 0..<uiView.subviews.count{

        uiView.subviews[i].frame = CGRect(x: 0, y: 0,width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * CGFloat((data.count)))
    }
}

class Coordinator : NSObject,UIScrollViewDelegate{

    var parent : PlayerScrollView
    var index = 0

    init(parent1 : PlayerScrollView) {

        parent = parent1
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let currentindex = Int(scrollView.contentOffset.y / UIScreen.main.bounds.height)

        if index != currentindex{

            index = currentindex

            for i in 0..<parent.data.count{
                
                parent.data[i].player.seek(to: .zero)
                parent.data[i].player.pause()
            }

            parent.data[index].player.play()

            parent.data[index].player.actionAtItemEnd = .none

            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { [self] _ in
                parent.data[index].player.seek(to: .zero)
                parent.data[index].player.play()
            }
        }
    }
}
}
