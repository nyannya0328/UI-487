//
//  Home.swift
//  UI-487
//
//  Created by nyannyan0328 on 2022/03/01.
//

import SwiftUI
import AVFoundation

struct Home: View {
    
    @State var progress : CGFloat = 0
    
    @State var currentImage : UIImage?
    @State var url : URL = URL(fileURLWithPath: Bundle.main.path(forResource: "Mountains - 59291", ofType: ".mp4") ?? "")
    var body: some View {
        VStack{
            
            
            VStack{
                
                HStack{
                    
                    
                    Button {
                        
                    } label: {
                        
                        Image(systemName: "chevron.left")
                         
                        
                    }
                    
                    Spacer()
                    
                    NavigationLink("Button"){
                        
                        
                        if let currentImage = currentImage {
                            
                            
                            Image(uiImage: currentImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 200)
                                .cornerRadius(15)
                        }
                    }
                    
                }
                .font(.caption.weight(.semibold))
                .foregroundColor(.black)
                .overlay{
                    
                    Text("Done")
                }
                
                

                
                
                Divider()
                    .background(.bar)
            }
            .frame(maxHeight:.infinity,alignment: .top)
            
            
            GeometryReader{proxy in
                
                
                let size = proxy.size
                
                
                ZStack{
                    
                    
                    
                    PreViewPlayer(url: $url, progress: $progress)
                        .cornerRadius(10)
                    
                    
                    
                }
                .frame(width: size.width, height: size.height)
                
                
                
               
                
            }
            .frame(width: 200, height: 300)
            
            Text("To select a cover image chose a from\nyour video or an image from your camera roll.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.vertical,30)
            
            let size = CGSize(width: 400, height: 400)
            
            VideoCaverScroller(videoURL: $url, progress: $progress,imageSize: size,coverImage: $currentImage)
                .padding(.top,20)
                .padding(.horizontal,15)
            
            
            Button {
                
            } label: {
                
                Label {
                    
                    Text("Add From Camera Roll")
                    
                } icon: {
                    
                    
                    Image(systemName: "plus")
                }
                .font(.caption.weight(.bold))
                .foregroundColor(.gray)

            }
            .padding(.top,20)
         
            
            
            
            
            
            
        }
        .padding([.horizontal,.bottom])
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct VideoCaverScroller : View{
    
    @Binding var videoURL : URL
    
    @Binding var progress : CGFloat
    
    @State var imageSequence : [UIImage]?
    
    
    @State var offset : CGFloat = 0
    
    @GestureState var isDragging : Bool = false
    
    
    var imageSize : CGSize
    
    @Binding var coverImage : UIImage?
    
    var body: some View{
        
        
        GeometryReader{proxy in
            
            
            let size = proxy.size
            
            
            HStack(spacing:0){
                
                
                
                
                if let imageSequence = imageSequence {
                    
                    ForEach(imageSequence,id:\.self){index in
                        
                        
                        
                        GeometryReader{proxy in
                            let subSize = proxy.size
                            
                            
                            Image(uiImage: index)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: subSize.width, height: subSize.height)
                                .clipped()
                            
                        }
                        .frame(height:size.height)
                        
                    }
                }
                
                
            }
            .overlay(alignment: .leading, content: {
                
                
                ZStack(alignment: .leading) {
                    Color.black.opacity(0.25)
                        .frame(height: size.height)
            
                    PreViewPlayer(url: $videoURL, progress: $progress)
                        .frame(width: 35, height: 60)
                        .cornerRadius(6)
                        .background(
                        
                        
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(.white,lineWidth: 3)
                            .padding(-3)
                        
                        )
                        .background(
                        
                        
                            RoundedRectangle(cornerRadius: 6)
                                .strokeBorder(.black.opacity(0.25))
                                .padding(-5)
                        
                        
                        )
                        .offset(x: offset)
                        .gesture(
                        
                        
                            DragGesture().updating($isDragging, body: { _, out, _ in
                                
                                
                                out = true
                            })
                            .onChanged({ value in
                                
                            
                                var translation = (isDragging ? value.location.x - 17.5 : 0)
                                
                                translation = (translation > 0 ? translation : 0)
                                
                                
                                translation = (translation > size.width - 35 ? size.width - 35 : translation)
                                
                                
                                offset = translation
                                
                                self.progress = (translation / (size.width - 35))
                                
                                
                                
                                
                            })
                            .onEnded({ _ in
                                
                                
                                retriviewCoverImageAt(progress: progress, size: imageSize) { image in
                                    
                                    
                                    self.coverImage = image
                                    
                                    
                                }
                            })
                        
                        
                        )
                        
                    
                    
                    
                }
                
                
            })
            .onAppear {
                if imageSequence == nil{
                    
                    generateImageSequece()
                }
            }
            .onChange(of: videoURL) { _ in
                
                
                progress = 0
                offset = .zero
                coverImage = nil
                imageSequence = nil
                
                generateImageSequece()
                
                retriviewCoverImageAt(progress: progress, size: imageSize) { image in
                    
                    
                    self.coverImage = image
                }
                
                
                
            }
            
            
        }
        .frame(height:50)
    }
    
    
    func generateImageSequece(){
        
        
        let parts = (videoDuration() / 2)
        
        
        (0..<10).forEach { index in
            
            
            let progress = (CGFloat(index) * parts) / videoDuration()
            
            
            retriviewCoverImageAt(progress: progress, size: CGSize(width: 100,height: 100)) { image in
                
                
                if imageSequence == nil{imageSequence = []}
                
                imageSequence?.append(image)
            }
        }
        
        
    }
    
    
    
    
    func retriviewCoverImageAt(progress : CGFloat,size : CGSize,competition : @escaping(UIImage) -> ()){
        
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            let asset = AVAsset(url: videoURL)
            let generator = AVAssetImageGenerator(asset: asset)
            
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = size
            
            
            let time = CMTime(seconds: progress * videoDuration(), preferredTimescale: 600)
            
            
            do{
                
                let image = try generator.copyCGImage(at: time, actualTime: nil)
                
                let cover = UIImage(cgImage: image)
                
                
                DispatchQueue.main.async {
                    
                    
                    competition(cover)
                    
                }
                
                
            }
            catch{
                
                
                print(error.localizedDescription)
            }
            
            
        }
        
        
    }
    
    func videoDuration() -> Double{
        
        
        let asset = AVAsset(url: videoURL)
        
        return asset.duration.seconds
    }
}
