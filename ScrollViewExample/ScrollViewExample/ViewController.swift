//
//  ViewController.swift
//  ScrollViewExample
//
//  Created by MAVİ on 21.01.2022.
//

import UIKit

class ViewController: UIViewController {
    
  
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageController: UIPageControl!
    
    var images : [UIImage] = []
    var contentWidth : CGFloat = 0.0
    var timer = Timer()
    var second : Int = 5
    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      
        images.append(UIImage(named: "theSimpsons")!)
        images.append(UIImage(named: "Homer")!)
        images.append(UIImage(named: "Bart")!)
        images.append(UIImage(named: "Lisa")!)
        images.append(UIImage(named: "Maggie")!)
        images.append(UIImage(named: "Marge")!)
        
        for i in 0..<images.count {
            
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(i)
            frame.size = self.scrollView.frame.size
            
            let imageView = UIImageView()
            imageView.image = images[i]
            imageView.contentMode = .scaleAspectFit
            imageView.frame = frame
            self.scrollView.addSubview(imageView)
            
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width * CGFloat(images.count), height: scrollView.frame.size.height)

    
        
    }

    
    @IBAction func slaytModeStartButtonTapped(_ sender: UIButton) {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(didSlaytModeEnabled), userInfo: nil, repeats: true)
    }
    
    @IBAction func slaytModeEndButtonTapped(_ sender: UIButton) {
        timer.invalidate()
    }
    
    @objc func didSlaytModeEnabled() {
        if self.scrollView.contentOffset.x < (self.scrollView.contentSize.width - self.view.frame.width) {
            self.scrollView.contentOffset.x += self.view.bounds.width
        } else if self.scrollView.contentOffset.x > 0 {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.frame.size.width * CGFloat(0), y: 0)
        }
    }
}



extension ViewController :UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      //  let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        self.pageController.currentPage = Int (self.scrollView.contentOffset.x / CGFloat(375))
    }
}

