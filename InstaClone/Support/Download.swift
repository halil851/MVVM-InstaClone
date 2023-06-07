//
//  Download.swift
//  InstaClone
//
//  Created by halil dikişli on 7.06.2023.
//

import UIKit.UIImage
import SDWebImage

struct Download: ImageDownload {
    
    func image(with url: URL?) async throws -> UIImage{
        guard let url = url else {
            throw ErrorTypes.invalidUrl
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            SDWebImageManager.shared.loadImage(with: url, progress: nil) {image, _, error, _, _, _ in
                
                switch (image, error) {
                case let (_, error?):
                    continuation.resume(throwing: error)
                case let (image?, _):
                    continuation.resume(returning: image)
                default:
                    continuation.resume(throwing: ErrorTypes.imageLoadFailed)
                }
            }
        }
    }
}
