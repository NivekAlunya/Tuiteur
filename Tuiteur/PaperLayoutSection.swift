//
//  PaperLayoutSection.swift
//  pocApp
//
//  Created by Kevin Launay on 5/9/16.
//  Copyright © 2016 Kevin Launay. All rights reserved.
//

import UIKit

class PaperLayoutSection: NSObject {
    
    var frame: CGRect
    let itemInsets: UIEdgeInsets
    var intervals: [CGRect]
    var items:[Int: CGRect]
    
    var numberOfItems: Int {
        get {
            return items.count
        }
    }
    
    init(origin: CGPoint, width: CGFloat, itemInsets: UIEdgeInsets) {
        self.itemInsets = itemInsets
        self.frame = CGRectMake(origin.x, origin.y, width, 0.0)
        self.items = [Int: CGRect]()
        self.intervals = [CGRect]()
        self.intervals.append(CGRectMake(0, 0, width, 0))
        //self.intervals.append(CGSize)
    }
    
    var booDebug = false
    
    func debug<T>(s: T) {
        if booDebug {
            print(s)
        }
    }
    
    func addItemOfSize(size: CGSize, forIndex indexItem: Int) {
        
        debug("----Process item \(indexItem)------")
        print(size)
        let margin = CGFloat(8.0)
        let sz = CGSizeMake(size.width, size.height)
        var (ranges, frames) = computeIntervalsCanFitToSize(sz, intervals: self.intervals)
        
        if let index = searchPosition(frames, forSize: size) {
            
            
            let frame = CGRectMake(frames[index].origin.x , frames[index].origin.y + frames[index].height, size.width, size.height)
            
            let lastFrame = self.intervals[ranges[index].end]
            
            self.items[indexItem] = CGRectMake(self.frame.origin.x + frame.origin.x, self.frame.origin.y + frame.origin.y, frame.width, frame.height)
            
            self.intervals.removeRange(ranges[index].start...ranges[index].end)

            intervals.insert(CGRectMake(frame.origin.x, 0.0, frame.width, frame.origin.y + frame.height), atIndex: ranges[index].start)
            
            if frames[index].width - frame.width > 0 {
                let otherFrame = CGRectMake(frame.origin.x + frame.width, lastFrame.origin.y, frames[index].width - frame.width , lastFrame.height)
                intervals.insert(otherFrame, atIndex: ranges[index].start + 1)
            }
            if self.frame.height < frame.origin.y + frame.height {
                self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.width, frame.origin.y + frame.height)
            }
        }
        debug("----intervals---")
        debug(intervals)
    }
    
    func computeIntervalsCanFitToSize(size: CGSize, intervals: [CGRect]) -> ([(start:Int, end:Int, spaceLost:Double)],[CGRect]) {
        var frames = [CGRect]()
        var ranges = [(start:Int, end:Int, spaceLost:Double)]()
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        var areaLost: Double = 0.0
        var end = 0
        
        for (index, rect) in intervals.enumerate() {
            width = rect.width
            height = rect.height
            end = index
            if width < size.width && index + 1 < intervals.count {
                for i in (index + 1) ..< intervals.count {
                    areaLost = Double((intervals[i].height - height) * intervals[i].width)
                    width += intervals[i].width
                    height = intervals[i].height > height ? intervals[i].height : height
                    if width >= size.width {
                        end = i
                        break
                    }
                }
            }
            if width >= size.width {
                frames.append(CGRectMake(rect.origin.x, rect.origin.y, width, height))
                //compute area lost in percent
                let area = Double(width * height) ?? 0.0
                let areaValues = (index, end , area > 0 ? areaLost / area : 0.0)
                if areaValues.2 > 0.0 {
                    print(areaValues)
                }
                ranges.append(areaValues)
            }
        }
        return (ranges, frames)
    }
    
    func frameForItemAtIndex(index: Int) -> CGRect {
        return items[index] ?? CGRectZero
    }
    
    private func searchPosition(intervals: [CGRect], forSize size: CGSize) -> Int? {
        var selected: Int?
        
        for (index, space) in intervals.enumerate() {
            if size.width <= space.width {
                if let sel = selected {
                    if space.height < intervals[sel].height - (size.height / 5) {
                        selected = index
                    }
                } else {
                    selected = index
                }
            }
        }
        return selected
//        return selectedHigherCoverage ?? selectedPerfect ?? selected
    }
}
