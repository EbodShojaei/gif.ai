import Foundation
import FalClient
import AVFoundation
import ImageIO
import UniformTypeIdentifiers

actor APIService {
    static let shared = APIService()
    private let fal: Client
    
    init() {
        self.fal = FalClient.withCredentials(.keyPair("SECRET"))
    }
    
    func generateGif(prompt: String) async throws -> Data {
        let input: Payload = .dict([
            "prompt": .string(prompt),
            "negative_prompt": .string("low quality, worst quality, deformed, distorted, disfigured, motion smear, motion artifacts, fused fingers, bad anatomy, weird hand, ugly"),
            "num_inference_steps": .int(30),
            "guidance_scale": .double(3.0),
            "seed": .int(Int.random(in: 1...999999))
        ])
        
        // Get video from API
        let result = try await fal.subscribe(
            to: "fal-ai/ltx-video",
            input: input
        ) { update in
            print("Progress update:", update)
        }
        
        // Extract video URL and download video
        guard case let .dict(resultDict) = result,
              case let .dict(videoDict)? = resultDict["video"],
              case let .string(urlString)? = videoDict["url"],
              let videoURL = URL(string: urlString) else {
            throw APIError.invalidResponse
        }
        
        // Download video data
        let (videoData, _) = try await URLSession.shared.data(from: videoURL)
        
        // Convert video to GIF
        return try await VideoConversionService.shared.convertVideoDataToGIF(videoData: videoData)
    }
}

enum APIError: Error {
    case invalidResponse
}
