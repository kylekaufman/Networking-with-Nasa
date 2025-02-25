//
//  PictureOfTheDayView.swift
//  Networking with Nasa
//
//  Created by Kyle Kaufman on 2/24/25.
//

import SwiftUI

struct NASAPictureOfTheDay: Codable {
    var copyright: String?
    var date: String
    var explanation: String
    var hdurl: String?
    var media_type: String
    var title: String
    var url: String
}

class PictureOfTheDayModel {
    var picture: NASAPictureOfTheDay?
    var imageURL: URL?
    
    func refresh() async {
        self.picture = await getPictureOfTheDay()
    }
    
    private func getPictureOfTheDay() async -> NASAPictureOfTheDay? {
        let session = URLSession(configuration: .default)
        if let url = URL(string: "https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY") {
            let request = URLRequest(url: url)
            do {
                let (data, response) = try await session.data(for: request)
                let decoder = JSONDecoder()
                let picture = try decoder.decode(NASAPictureOfTheDay.self, from: data)
                self.imageURL = URL(string: picture.url)
                return picture
            }
            catch {
                print(error)
            }
        }
        return nil
    }
}

struct PictureOfTheDayView: View {
    @State var fetchingPicture = false
    @State var pictureModel = PictureOfTheDayModel()
    
    func loadPicture() {
        fetchingPicture = true
        Task {
            await pictureModel.refresh()
            fetchingPicture = false
        }
    }
    
    var body: some View {
        VStack {
            Text(pictureModel.picture?.title ?? "")
                .font(.title2)
                .padding()
            
            AsyncImage(url: pictureModel.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
            } placeholder: {
                if fetchingPicture {
                    ProgressView()
                }
            }
            
            Text(pictureModel.picture?.explanation ?? "")
                .font(.caption)
                .padding()
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
        .onAppear {
            loadPicture()
        }
    }
}

#Preview {
    PictureOfTheDayView()
}

