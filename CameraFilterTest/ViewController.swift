//
//  ViewController.swift
//  CameraFilterTest
//
//  Created by 이채원 on 2017. 6. 7..
//  Copyright © 2017년 이채원. All rights reserved.
//

import UIKit
import GPUImage
import AVFoundation

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var renderView: RenderView!
    
    let videoCamera:Camera?
    
    let saturation = filterOperations[0]
    let contrast = filterOperations[1]
    let brightness = filterOperations[2]
    let levels = filterOperations[3]
    let exposure = filterOperations[4]
    let rgb = filterOperations[5]
    let whiteBalance = filterOperations[7]
    let unsharpMask = filterOperations[11]
    let gamma = filterOperations[16]
    let sepia = filterOperations[19]
    let vibrance = filterOperations[25]
    let shadowTint = filterOperations[26]
    let monochrome = filterOperations[8]
    let sharpen = filterOperations[10]
    let highlight = filterOperations[17]
    let haze = filterOperations[18]
    
    var filters: [FilterOperationInterface]?
    
    var values: [String: Float] = [:]
    
    private var isFirstLoad = true
    
    required init(coder aDecoder: NSCoder)
    {
        do {
            
            videoCamera = try Camera(sessionPreset: AVCaptureSessionPreset1280x720, location:.backFacing)
            videoCamera!.runBenchmark = false
        } catch {
            videoCamera = nil
            print("Couldn't initialize camera with error: \(error)")
        }
        
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.backgroundColor = UIColor.clear
        self.collectionView.backgroundView = UIView(frame: CGRect.zero)
        
        self.filters = [saturation, contrast, brightness, levels, exposure, rgb, whiteBalance, unsharpMask, gamma, sepia, vibrance, shadowTint, monochrome, sharpen, highlight, haze]
        
        self.configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.isFirstLoad {
            for filter in self.filters! {
                let configure = filter.sliderConfiguration
                
                switch configure {
                case let .enabled(minimumValue, maximumValue, initialValue):
                    
                    self.values[filter.titleName] = initialValue
                    
                    filter.updateBasedOnSliderValue(initialValue)
                    break
                default:
                    break
                }
            }
            
            self.isFirstLoad = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ResultSegue" {
            let toVC = segue.destination as! ResultTableViewController
            
            toVC.dataModel = self.values
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "SlidersCell", for: indexPath) as! SlidersCell
        
        let sliders = [cell.slider1, cell.slider2, cell.slider3, cell.slider4, cell.slider5, cell.slider6]
        let labels = [cell.name1, cell.name2, cell.name3, cell.name4, cell.name5, cell.name6]
        
        for i in 0..<6 {
            
            if indexPath.item * 6 + i >= self.filters!.count {
                break
            }
            
            if let filter = self.filters?[indexPath.item * 6 + i] {
                let configure = filter.sliderConfiguration
                
                labels[i]?.isHidden = false
                sliders[i]?.isHidden = false
                
                labels[i]?.text = filter.titleName
                
                switch configure {
                case let .enabled(minimumValue, maximumValue, initialValue):
                    
                    sliders[i]?.minimumValue = minimumValue
                    sliders[i]?.maximumValue = maximumValue
                    sliders[i]?.value = self.values[filter.titleName]!
                    
                    filter.updateBasedOnSliderValue(self.values[filter.titleName]!)
                    
                    break
                default:
                    break
                }
                
                sliders[i]?.addTarget(self, action: #selector(changeFilterValue(sender:)), for: .valueChanged)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.filters!.count % 6 != 0 {
            return self.filters!.count / 6 + 1
        } else {
            return self.filters!.count / 6
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func configureView() {
        
        
        videoCamera?.addTarget(self.filters![0].filter)
        
        for i in 1..<self.filters!.count {
            self.filters![i-1].filter.addTarget(self.filters![i].filter)
        }
        
        self.filters![self.filters!.count - 1].filter.addTarget(self.renderView)
        
        videoCamera?.startCapture()
    }
    
    func changeFilterValue(sender: UISlider) {
        
        let value = Float(sender.value)
        let tag = sender.tag
        
        let cellIndex = self.collectionView.indexPathsForVisibleItems[0].item
        
        self.filters![cellIndex * 6 + tag - 1].updateBasedOnSliderValue(value)
        
        self.values[self.filters![cellIndex * 6 + tag - 1].titleName] = value
    }
    
    @IBAction func initiateButtonPressed(_ sender: Any) {
        
        for i in 0..<self.filters!.count {
            
            let filter = self.filters![i]
            let configure = filter.sliderConfiguration
            
            switch configure {
            case let .enabled(minimumValue, maximumValue, initialValue):
                
                filter.updateBasedOnSliderValue(initialValue)
                self.values[filter.titleName] = initialValue
                
                break
            default:
                break
            }
        }
        
        self.collectionView.reloadData()
    }
    @IBAction func unwindToViewController(segue: UIStoryboardSegue) {
        
    }
}

class SlidersCell: UICollectionViewCell {
    
    @IBOutlet var name1: UILabel!
    @IBOutlet var name2: UILabel!
    @IBOutlet var name3: UILabel!
    @IBOutlet var name4: UILabel!
    @IBOutlet var name5: UILabel!
    @IBOutlet var name6: UILabel!
    @IBOutlet var slider1: UISlider!
    @IBOutlet var slider2: UISlider!
    @IBOutlet var slider3: UISlider!
    @IBOutlet var slider4: UISlider!
    @IBOutlet var slider5: UISlider!
    @IBOutlet var slider6: UISlider!
}
