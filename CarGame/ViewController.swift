//
//  ViewController.swift
//  CarGame
//
//  Created by admin on 12/10/2022.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Private properties
    private let carView = UIImageView(image: UIImage(named: "car"))
    private let carWidth: CGFloat = 50
    private let carHeight: CGFloat = 100
    private let lineWidth: CGFloat = 2
    private let lineHeight: CGFloat = 30
    private let barrierSize: CGFloat = 100
    private let uiImage = UIImage(named: "barrier")
    
    private var defaultSpacing: CGFloat = 0
    private var gameTimer: Timer?
    private var isFirstLoad = true
    
    private var carLocation: Location = .center {
        willSet (newLocation) {
            layoutCar(at: newLocation)
        }
    }
    
    // MARK: - Override methods
    override func viewWillLayoutSubviews() {
        if isFirstLoad {
            initView()
        }
    }
    
    // MARK: - Private methods
    private func initView() {
        defaultSpacing = (view.frame.width - carWidth * 3) / 4
        
        setupCar()
        setupTrack()
        view.addSubview(carView)
        layoutCar(at: .center)
        createBarrier(xCoordinate: view.frame.width / 6 - barrierSize / 2, delay: 2)
        createBarrier(xCoordinate: view.frame.width / 2 - barrierSize / 2, delay: 10)
        createBarrier(xCoordinate: view.frame.width * 5 / 6 - barrierSize / 2, delay: 7)
        
        isFirstLoad = false
    }
    
    private func setupTrack() {
        let firstSeparator = UIView()
        firstSeparator.frame = CGRect(
            x: view.frame.width / 3,
            y: 0,
            width: 2,
            height: view.frame.size.height
        )
        firstSeparator.backgroundColor = .gray
        
        let secondSeparator = UIView()
        secondSeparator.frame = CGRect(
            x: view.frame.width * 2 / 3,
            y: 0,
            width: 2,
            height: view.frame.size.height
        )
        secondSeparator.backgroundColor = .gray
        
        view.addSubview(firstSeparator)
        view.addSubview(secondSeparator)
        drawDottedLine(start: CGPoint(x: view.frame.width / 6, y: lineHeight),
                       end: CGPoint(x: view.frame.width / 6, y: view.frame.height
                                   ), view: view)
        
        drawDottedLine(start: CGPoint(x: view.frame.width / 2, y: lineHeight),
                       end: CGPoint(x: view.frame.width / 2, y: view.frame.height
                                   ), view: view)
        
        drawDottedLine(start: CGPoint(x: view.frame.width * 5 / 6, y: lineHeight),
                       end: CGPoint(x: view.frame.width * 5 / 6, y: view.frame.height
                                   ), view: view)
    }
    
    func drawDottedLine(start p0: CGPoint, end p1: CGPoint, view: UIView) {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineDashPattern = [30, 30]
        
        let path = CGMutablePath()
        path.addLines(between: [p0, p1])
        shapeLayer.path = path
        view.layer.addSublayer(shapeLayer)
        
        animateRoad(view: shapeLayer)
    }
    
    private func animateRoad(view: CAShapeLayer) {
        var animation = CABasicAnimation(keyPath: "position.y")
        
        animation.fromValue = view.position.y
        animation.toValue = 30
        animation.duration = 1.0
        animation.autoreverses = false
        animation.repeatCount = .infinity
        view.add(animation, forKey: "position.y")
    }
    
    private func createBarrier(xCoordinate: CGFloat, delay: Double) {
        let imageView = UIImageView(image: uiImage)
        view.addSubview(imageView)
        imageView.frame = CGRect(x: xCoordinate, y: -100, width: barrierSize, height: barrierSize)
        
        let imageViewSecond = UIImageView(image: uiImage)
        view.addSubview(imageViewSecond)
        imageViewSecond.frame = CGRect(x: xCoordinate, y: -100, width: barrierSize, height: barrierSize)
        
        let spacing = Double(view.frame.height)
        let v = 150.0
        
        let s1 = spacing + 750
        let s2 = spacing + 1000
        
        let t1 = s1/v
        let t2 = s2/v
        
        UIView.animate(withDuration: t1, delay: delay, options: [ .curveLinear, .repeat], animations: {
            imageView.frame.origin.y += s1
        })
        
        UIView.animate(withDuration: t2, delay: delay / 2, options: [ .curveLinear, .repeat], animations: {
            imageViewSecond.frame.origin.y += s2
        })
    }
    
    private func setupCar() {
        carView.frame = CGRect(
            x: getOriginX(for: .center),
            y: view.frame.size.height - carHeight * 2,
            width: carWidth,
            height: carHeight
        )
        
        addSwipeGesture(to: view, direction: .left)
        addSwipeGesture(to: view, direction: .right)
    }
    
    private func layoutCar(at location: Location) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
            self.carView.frame.origin.x = self.getOriginX(for: location)
        }
    }
    
    private func getOriginX(for location: Location) -> CGFloat {
        switch location {
        case .left:
            return defaultSpacing - carWidth / 2
        case .center:
            return defaultSpacing * 2 + carWidth
        case .right:
            return defaultSpacing * 3 + carWidth * 2.5
        }
    }
    
    private func addSwipeGesture(to view: UIView, direction: UISwipeGestureRecognizer.Direction) {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(moveCar))
        swipeGesture.direction = direction
        view.addGestureRecognizer(swipeGesture)
    }
    
    @objc private func moveCar(_ gestureRecognizer: UISwipeGestureRecognizer) {
        switch gestureRecognizer.direction {
        case .left:
            if carLocation == .center { carLocation = .left }
            if carLocation == .right { carLocation = .center }
        case .right:
            if carLocation == .center { carLocation = .right }
            if carLocation == .left { carLocation = .center }
        default:
            return
        }
    }
    
    //    private func isGameOver() {
    //        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
    //            let check = self.view.subviews.filter {
    //                $0 is UIImageView
    //            }
    //            for subView in check {
    //                guard let image = subView as? UIImageView
    //                else { return }
    //                if self.carView.frame.intersects(image.frame){
    //                    self.showAlert()
    //                }
    //            }
    //        }
    //    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Game is over", message: "You can start a new game", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true) {
            self.initView()
        }
    }
}
