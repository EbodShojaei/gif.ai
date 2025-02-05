import Foundation
import AVFoundation
import ImageIO
import UniformTypeIdentifiers

actor VideoConversionService {
    static let shared = VideoConversionService()
    
    private init() {}
    
    func convertVideoDataToGIF(videoData: Data) async throws -> Data {
        // Save video data to temporary file
        let temporaryVideoURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".mp4")
        try videoData.write(to: temporaryVideoURL)
        
        // Convert to GIF
        let gifData = try await convertVideoToGIF(videoURL: temporaryVideoURL)
        
        // Clean up temporary file
        try? FileManager.default.removeItem(at: temporaryVideoURL)
        
        return gifData
    }
    
    private func convertVideoToGIF(videoURL: URL) async throws -> Data {
        let asset = AVURLAsset(url: videoURL)
        let duration = try await asset.load(.duration)
        let frameRate: Double = 10 // Adjust for quality vs file size
        
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        
        let frameCount = Int(duration.seconds * frameRate)
        
        // Extract frames
        let frames = try await extractFrames(generator: generator, frameCount: frameCount, frameRate: frameRate)
        
        // Create GIF from frames
        return try await createGIFFromImages(frames)
    }
    
    private func extractFrames(generator: AVAssetImageGenerator, frameCount: Int, frameRate: Double) async throws -> [CGImage] {
        try await withThrowingTaskGroup(of: CGImage.self) { group in
            for frameNumber in 0..<frameCount {
                let time = CMTime(seconds: Double(frameNumber) / frameRate, preferredTimescale: 600)
                
                group.addTask {
                    try await withCheckedThrowingContinuation { continuation in
                        generator.generateCGImageAsynchronously(for: time) { cgImage, _, error in
                            if let cgImage = cgImage {
                                continuation.resume(returning: cgImage)
                            } else {
                                continuation.resume(throwing: error ?? VideoConversionError.frameExtractionFailed)
                            }
                        }
                    }
                }
            }
            
            var frames: [CGImage] = []
            for try await frame in group {
                frames.append(frame)
            }
            return frames
        }
    }
    
    private func createGIFFromImages(_ images: [CGImage]) async throws -> Data {
        let data = NSMutableData()
        
        guard let destination = CGImageDestinationCreateWithData(data, UTType.gif.identifier as CFString, images.count, nil) else {
            throw VideoConversionError.gifCreationFailed
        }
        
        let gifProperties = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFHasGlobalColorMap: true,
                kCGImagePropertyColorModel: kCGImagePropertyColorModelRGB,
                kCGImagePropertyDepth: 8,
                kCGImagePropertyGIFLoopCount: 0
            ]
        ] as CFDictionary
        
        let frameProperties = [
            kCGImagePropertyGIFDictionary: [
                kCGImagePropertyGIFDelayTime: 0.1
            ]
        ] as CFDictionary
        
        CGImageDestinationSetProperties(destination, gifProperties)
        
        for image in images {
            CGImageDestinationAddImage(destination, image, frameProperties)
        }
        
        guard CGImageDestinationFinalize(destination) else {
            throw VideoConversionError.gifCreationFailed
        }
        
        return data as Data
    }
}

enum VideoConversionError: Error {
    case frameExtractionFailed
    case gifCreationFailed
}
