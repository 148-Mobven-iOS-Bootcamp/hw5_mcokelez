//
//  ScrollViewController.swift
//  ScrollViewExample
//
//  Created by MAVİ on 21.01.2022.
//

import UIKit

class ScrollViewController: UIViewController{
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: Variables
    
    var timer = Timer()
    var scrollView = UIScrollView()
    var frame: CGRect = CGRect(x:0, y:0, width:0, height:0)
    var images : [UIImage] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView = UIScrollView(frame: CGRect(x:0, y:0,
                                                width:self.view.frame.width,
                                                height: self.view.frame.height - CGFloat(150)))
        
        
        
        images.append(UIImage(named: "theSimpsons")!)
        images.append(UIImage(named: "Homer")!)
        images.append(UIImage(named: "Bart")!)
        images.append(UIImage(named: "Lisa")!)
        images.append(UIImage(named: "Maggie")!)
        images.append(UIImage(named: "Marge")!)
        
        scrollView.delegate = self
        scrollView.isPagingEnabled = true
        
        self.view.addSubview(scrollView)
        
        for i in 0..<images.count {
            
            frame.origin.x = self.scrollView.frame.size.width * CGFloat(i)
            frame.size = self.scrollView.frame.size
            
            let imageView = UIImageView()
            imageView.image = images[i]
            imageView.contentMode = .scaleAspectFit
            imageView.frame = frame
            self.scrollView.addSubview(imageView)
            
            var slaytModeOn = UIButton()
            slaytModeOn = UIButton(frame: CGRect(x:15, y:37, width:150, height: 50 ))
            slaytModeOn.setTitle("Slayt Mode On", for: .normal)
            slaytModeOn.addTarget(self, action: #selector(runTimer), for: .touchUpInside)
            scrollView.addSubview(slaytModeOn)
            
            var slaytModeOff = UIButton()
            slaytModeOff = UIButton(frame: CGRect(x:160, y:37, width:150, height: 50 ))
            slaytModeOff.setTitle("Slayt Mode Off", for: .normal)
            slaytModeOff.addTarget(self, action: #selector(stopTimer), for: .touchUpInside)
            scrollView.addSubview(slaytModeOff)
            
        }
        
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.size.width * CGFloat(images.count),height: self.scrollView.frame.size.height)
    }
    
    
    /* slayt mode off button tapped **/
    
    @objc func stopTimer(){
        timer.invalidate()
    }
    
    /*slayt mode on button tapped **/
    
    @objc func runTimer(){
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(didSlaytModeEnabled), userInfo: nil, repeats: true)
    }
    
    /* Activate slide scroll view automatically pagination every 5 seconds when timer starts**/
    
    @objc func didSlaytModeEnabled() {
        if self.scrollView.contentOffset.x < (self.scrollView.contentSize.width - self.view.frame.width) {
            self.scrollView.contentOffset.x += self.view.bounds.width
        } else if self.scrollView.contentOffset.x > 0 {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.frame.size.width * CGFloat(0), y: 0)
        }
    }
    
}

// MARK: ScrollViewDelegate

extension ScrollViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        /*pageControl settings*/
        
        let pageNumber = Int(self.scrollView.contentOffset.x / CGFloat(375))
        self.pageControl.currentPage = pageNumber
        
        /* Infinite scroll but left side*/
        
        if self.scrollView.contentOffset.x > 0 {
            if self.scrollView.contentOffset.x >= self.scrollView.frame.size.width * CGFloat(images.count){
                self.scrollView.contentOffset = CGPoint(x: self.scrollView.frame.size.width, y: 0)
            }
        } else if self.scrollView.contentOffset.x < 0 {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.frame.size.width * CGFloat(images.count - 1), y: 0)
        }
    }
}
