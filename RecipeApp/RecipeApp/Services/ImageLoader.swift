//
//  ImageLoader.swift
//  RecipeApp
//
//  Created by Srilu Rao on 4/17/25.
//

import UIKit
import ImageIO

public class ImageLoader {
    public static let shared = ImageLoader()
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let imageProcessingQueue = DispatchQueue(label: "com.recipeapp.imageprocessing", qos: .userInitiated)
    
    public init() {
        cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("RecipeImages")
        createCacheDirectory()
    }
    
    private func createCacheDirectory() {
        guard !fileManager.fileExists(atPath: cacheDirectory.path) else { return }
        try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
    
    // Enhanced cache path with size information
    private func cachePath(for url: URL, recipeId: String, targetSize: CGSize?) -> URL {
        let sizeKey = targetSize.map { "\(Int($0.width))x\(Int($0.height))" } ?? "original"
        let filename = "\(recipeId)_\(sizeKey)_\(url.lastPathComponent)"
        return cacheDirectory.appendingPathComponent(filename)
    }
    
    
    public func loadImage(
        url: URL?,
        recipeId: String,
        targetSize: CGSize? = nil,
        highQuality: Bool = true
    ) async -> UIImage? {
        guard let url = url else { return nil }
        
        // Check cache first
        let cacheURL = cachePath(for: url, recipeId: recipeId, targetSize: targetSize)
        if let cachedImage = UIImage(contentsOfFile: cacheURL.path) {
            return cachedImage
        }
        
        // Download and process image
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Process image in background
            return try await withCheckedThrowingContinuation { continuation in
                imageProcessingQueue.async {
                    do {
                        let image: UIImage
                        
                        if let targetSize = targetSize {
                            // Downsample to target size
                            image = try self.downsampleImage(data: data, to: targetSize, highQuality: highQuality)
                        } else {
                            // Load original image
                            guard let loadedImage = UIImage(data: data) else {
                                throw ImageError.decodingFailed
                            }
                            image = loadedImage
                        }
                        
                        // Apply subtle sharpening for smaller images
                        let finalImage = targetSize != nil ? image.applyingSharpening() : image
                        
                        // Save to cache
                        if let imageData = finalImage.pngData() {
                            try imageData.write(to: cacheURL)
                        }
                        
                        continuation.resume(returning: finalImage)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        } catch {
            print("Image loading failed: \(error)")
            return nil
        }
    }
    
    // Efficient downsampling for large images
    private func downsampleImage(data: Data, to size: CGSize, highQuality: Bool) throws -> UIImage {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            throw ImageError.decodingFailed
        }
        
        let maxDimension = max(size.width, size.height) * (highQuality ? 2.0 : 1.0)
        let options: [CFString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: maxDimension,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true
        ]
        
        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            throw ImageError.downsamplingFailed
        }
        
        return UIImage(cgImage: downsampledImage)
    }
}


extension UIImage {
    func applyingSharpening(amount: CGFloat = 0.15) -> UIImage {
        guard let ciImage = CIImage(image: self) else { return self }
        
        let filter = CIFilter(name: "CISharpenLuminance")!
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(amount, forKey: kCIInputSharpnessKey)
        
        guard let outputImage = filter.outputImage,
              let cgImage = CIContext().createCGImage(outputImage, from: outputImage.extent) else {
            return self
        }
        
        return UIImage(cgImage: cgImage)
    }
}

enum ImageError: Error {
    case decodingFailed
    case downsamplingFailed
}

extension ImageLoader {
    func clearCache() throws {
        if fileManager.fileExists(atPath: cacheDirectory.path) {
            try fileManager.removeItem(at: cacheDirectory)
        }
        createCacheDirectory()
    }
}
