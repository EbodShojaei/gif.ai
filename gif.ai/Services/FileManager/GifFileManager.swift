//
//  GifFileManager.swift
//  gif.ai
//
//  Created by Ebod Shojaei on 2024-12-04.
//

import Foundation
import UniformTypeIdentifiers
import ImageIO
import MobileCoreServices

class GifFileManager {
    static let shared = GifFileManager()
    private init() {}
    
    func createTemporaryGIFFile(from data: Data) -> URL? {
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectory.appendingPathComponent("animated_gif_\(UUID().uuidString).gif")
        
        do {
            try data.write(to: fileURL)
            print("GIF file created at: \(fileURL)")
            return fileURL
        } catch {
            print("Error creating GIF file: \(error)")
            return nil
        }
    }
    
    func cleanupFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}
