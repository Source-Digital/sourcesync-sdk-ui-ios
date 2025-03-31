//
//  CircularProgressManager.swift
//  SourceSyncSDK
//
//  Created by ayman badawy on 30/03/2025.
//
import UIKit
/**
 * A helper class to manage circular progress indicator
 */
class CircularProgressManager {
    private weak var parentView: UIView?
    private var progressContainerView: UIView?
    private var progressLayer: CAShapeLayer?
    private var centerImageView: UIImageView?
    private var progressCompleteListener: (() -> Void)?
    private var progressAnimation: CABasicAnimation?
    
    init(_ parentView: UIView) {
        self.parentView = parentView
    }
    
    func setProgressCompleteListener(_ listener: @escaping () -> Void) {
        self.progressCompleteListener = listener
    }
    
    func getProgressContainerView() -> UIView? {
        return progressContainerView
    }
    
    func setupCircularProgress(withImage image: UIImage?) {
        removeProgressIndicator()
        
        guard let parentView = parentView else { return }
        
        // Create container for progress
        let containerSize: CGFloat = 70
        let container = UIView(frame: CGRect(x: 0, y: 0, width: containerSize, height: containerSize))
        container.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(container)
        
        // Position at top right
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20),
            container.widthAnchor.constraint(equalToConstant: containerSize),
            container.heightAnchor.constraint(equalToConstant: containerSize)
        ])
        
        // Create circular progress
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: containerSize/2, y: containerSize/2),
            radius: containerSize/2 - 4, // Adjust for stroke width
            startAngle: -CGFloat.pi / 2,
            endAngle: 3 * CGFloat.pi / 2,
            clockwise: true
        )
        
        // Background track
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        trackLayer.lineWidth = 8
        trackLayer.fillColor = UIColor.clear.cgColor
        container.layer.addSublayer(trackLayer)
        
        // Progress layer
        let progress = CAShapeLayer()
        progress.path = circularPath.cgPath
        progress.strokeColor = UIColor.green.cgColor
        progress.lineWidth = 8
        progress.fillColor = UIColor.clear.cgColor
        progress.strokeEnd = 1.0
        progress.lineCap = .round
        container.layer.addSublayer(progress)
        
        // Add center image if provided
        if let image = image {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                imageView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: containerSize * 0.6),
                imageView.heightAnchor.constraint(equalToConstant: containerSize * 0.6)
            ])
            
            self.centerImageView = imageView
        }
        
        self.progressContainerView = container
        self.progressLayer = progress
    }
    
    func startProgressAnimation(_ duration: TimeInterval) {
        guard let progressLayer = progressLayer else { return }
        
        // Stop any existing animation
        progressLayer.removeAllAnimations()
        
        // Create new animation
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = duration // Convert from milliseconds to seconds
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        // Set up completion callback
        animation.delegate = AnimationDelegate { [weak self] in
            self?.progressCompleteListener?()
        }
        
        progressLayer.add(animation, forKey: "progressAnimation")
        progressAnimation = animation
    }
    
    func removeProgressIndicator() {
        progressContainerView?.removeFromSuperview()
        progressContainerView = nil
        progressLayer = nil
        centerImageView = nil
        progressAnimation = nil
    }
    
    func setVisibility(_ visible: Bool) {
        progressContainerView?.isHidden = !visible
    }
}

// Helper class for CAAnimation completion
private class AnimationDelegate: NSObject, CAAnimationDelegate {
    private let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
    }
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            completion()
        }
    }
}
