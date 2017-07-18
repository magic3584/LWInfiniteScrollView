//
//  LWInfiniteScrollView.swift
//
//  Created by wang on 04/07/2017.
//  Copyright © 2017 wang. All rights reserved.
//

import UIKit

enum ViewMoveDirection {//View移动方向
    case none//不移动
    case left//把最右边的一个View放在最左边
    case right//把最左边的一个View放在最右边
}

class LWInfiniteView: UIView {
    
    //是不是用的jietu
    var isFake = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContentView(_ view: UIView, isFake: Bool = false) {
                
        if self.subviews.count != 0 {
            self.subviews[0].removeFromSuperview()
        }
        view.frame.origin = CGPoint(x: 0, y: 0)
        self.isFake = isFake
        self.addSubview(view)
    }
}

open class LWInfiniteScrollView: UIView {

    var contentScrollView: UIScrollView!
    var leftView: LWInfiniteView?
    var middleView: LWInfiniteView?
    var rightView: LWInfiniteView?
    var viewsArray = [LWInfiniteView?]()
    
    //当且只有两个数据源View的时候，生成两个截图
    var firstFakeView: UIView?
    var secondFakeView: UIView?
    
    var dataArray = [UIView]()
    
    //左中右，初始化总在中间 page = 1
    var lastPage = 1
    
    //初始化总是显示index = 0 的view
    var selectedViewIndex = 0
    
    var pageControl: UIPageControl!
    
    var timer: Timer!
    
    public init(frame: CGRect, viewsArray: Array<UIView>) {
        super.init(frame: frame)
        
        self.dataArray = viewsArray
        
        let width = frame.size.width
        let height = frame.size.height
        
        contentScrollView = {
            
            let scrollView = UIScrollView.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.isPagingEnabled = true
            scrollView.delegate = self
            self.addSubview(scrollView)
            
            if viewsArray.count >= 1 {
                leftView = LWInfiniteView.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
                leftView?.setContentView(self.dataArray[0])

                scrollView.addSubview(leftView!)
                self.viewsArray.append(leftView)
                scrollView.contentSize = CGSize(width: width, height: 0)
            }
            
            if viewsArray.count >= 2 {
                middleView = LWInfiniteView.init(frame: CGRect(x: width, y: 0, width: width, height: height))
                scrollView.addSubview(middleView!)
                self.viewsArray.append(middleView)
                
                rightView = LWInfiniteView.init(frame: CGRect(x: width * 2, y: 0, width: width, height: height))
                scrollView.addSubview(rightView!)
                self.viewsArray.append(rightView)
                
                scrollView.contentSize = CGSize(width: width * 3, height: 0)
                
                if viewsArray.count == 2 {
                    
                    firstFakeView = snapForView(self.dataArray[0])
                    secondFakeView = snapForView(self.dataArray[1])
                    
                    leftView?.setContentView(secondFakeView!, isFake: true)
                    middleView?.setContentView(self.dataArray[0])
                    rightView?.setContentView(self.dataArray[1])
                    
                } else {
                    leftView?.setContentView(self.dataArray.last!)
                    middleView?.setContentView(self.dataArray[0])
                    rightView?.setContentView(self.dataArray[1])
                }
                
                scrollView.setContentOffset(CGPoint(x: width, y: 0), animated: false)
            }
            
            
            return scrollView
        }()
        
        guard viewsArray.count > 1 else {
            return
        }
        
        pageControl = {
            let pageControl = UIPageControl()
            pageControl.frame=CGRect(x: 0, y: 20,width:self.dataArray.count * 20, height: 20)
            
            
            //页控件属性
            pageControl.backgroundColor=UIColor.clear
            pageControl.currentPage=0
            pageControl.numberOfPages = self.dataArray.count
            pageControl.currentPageIndicatorTintColor=UIColor.red
            pageControl.pageIndicatorTintColor=UIColor.lightGray
            pageControl.transform=CGAffineTransform.init(scaleX: 0.6, y: 0.6)
            
            pageControl.frame.origin.x = width - pageControl.frame.size.width
            self.addSubview(pageControl)
            
            return pageControl
        }()
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(LWInfiniteScrollView.moveNextPage), userInfo: nil, repeats: true)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    func moveViewAtIndexes(_ viewIndexes: [Int], direction: ViewMoveDirection) {
        
        switch direction {
        case .left://手向右滑动
            let movedView = viewsArray.removeLast()
            viewsArray.insert(movedView, at: 0)
            
            viewsArray[0]?.frame.origin.x = 0
            viewsArray[1]?.frame.origin.x = contentScrollView.frame.size.width
            viewsArray[2]?.frame.origin.x = contentScrollView.frame.size.width * 2
            
            if self.dataArray.count == 2 {
                viewsArray[1]?.setContentView(self.dataArray[selectedViewIndex])

                if selectedViewIndex == 0 {
                    viewsArray[0]?.setContentView(secondFakeView!, isFake: true)
                } else { //selectedViewIndex == 1
                    viewsArray[0]?.setContentView(firstFakeView!, isFake: true)
                }
                
            } else {
                viewsArray[0]?.setContentView(self.dataArray[self.leftIndex()])
            }
            
            
        case .right://手向左滑动
            let movedView = viewsArray.removeFirst()
            viewsArray.append(movedView)
            
            viewsArray[0]?.frame.origin.x = 0
            viewsArray[1]?.frame.origin.x = contentScrollView.frame.size.width
            viewsArray[2]?.frame.origin.x = contentScrollView.frame.size.width * 2
            
            if self.dataArray.count == 2 {
                viewsArray[1]?.setContentView(self.dataArray[selectedViewIndex])

                if selectedViewIndex == 0 {
                    viewsArray[2]?.setContentView(secondFakeView!, isFake: true)
                    
                } else {// selectedViewIndex == 1
                    viewsArray[2]?.setContentView(firstFakeView!, isFake: true)
                }
                
                
            } else {
                viewsArray[2]?.setContentView(self.dataArray[self.rightIndex()])

            }
            
        case .none:
            break
        }
        
        
    }
    
    //计算左中右的 index
    func leftIndex() -> Int  {
        var index = 0
        
        if selectedViewIndex == 0 {
            index = self.dataArray.count - 1
        } else {
            index = selectedViewIndex - 1
        }
        return index
    }
    
    func middleIndex(afterMove direction: ViewMoveDirection) {
        
        var index = 0
        
        switch direction {
            
        case .left://手向右滑动
        
            index = leftIndex()
            
        case .right://手向左滑动
            
            index = rightIndex()
            
        case .none:
            break
        }
        
        selectedViewIndex = index
    }
    
    func rightIndex() -> Int {
        return (selectedViewIndex + 1) % self.dataArray.count
    }
    
    @objc func moveNextPage() {
        UIView.animate(withDuration: 0.6, animations: {
            self.contentScrollView.contentOffset = CGPoint(x: self.contentScrollView.frame.size.width * 2, y: 0)

        }) { (_) in
            self.middleIndex(afterMove: .right)
            self.moveViewAtIndexes([2], direction: .right)
            
            self.contentScrollView.setContentOffset(CGPoint(x: self.contentScrollView.frame.size.width, y: 0), animated: false)
            
            self.lastPage = 1
            self.pageControl.currentPage = self.selectedViewIndex
        }
    }
    
    //预留：外部调用翻页
    open func nextPatch() {
        
        guard self.dataArray.count > 1 else {
            return
        }
        
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(LWInfiniteScrollView.moveNextPage), userInfo: nil, repeats: true)
        moveNextPage()
    }
    
    
    fileprivate func snapForView(_ view: UIView) -> UIImageView {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let snap = UIImageView(image: image)
//        let red = UIView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 20))
//        red.backgroundColor = UIColor.red
//        snap.addSubview(red)
        return snap
    }

}
extension LWInfiniteScrollView: UIScrollViewDelegate {
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.isUserInteractionEnabled = false
        
        guard self.dataArray.count > 1 else {
            return
        }
        
        timer.invalidate()
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        scrollView.isUserInteractionEnabled = true
        
        guard self.dataArray.count > 1 else {
            return
        }
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(LWInfiniteScrollView.moveNextPage), userInfo: nil, repeats: true)

        
        let page = Int(scrollView.contentOffset.x / scrollView.frame.size.width)
        
        if page == 1 { return }//并没有滑动翻页
        
        if page > lastPage {//手向左滑动
            
            self.middleIndex(afterMove: .right)
            moveViewAtIndexes([2], direction: .right)
            
        }else {
            
            self.middleIndex(afterMove: .left)
            moveViewAtIndexes([0], direction: .left)
            
        }
        
        scrollView.setContentOffset(CGPoint(x: scrollView.frame.size.width, y: 0), animated: false)
        
        lastPage = 1
        pageControl.currentPage = selectedViewIndex
        print(selectedViewIndex)

    }
}

extension UIView
{
    func copyView<T: UIView>() -> T {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! T
    }
    
    func copyView() -> UIView {
        self.isHidden = false //The copy not works if is hidden, just prevention
        let viewCopy = self.snapshotView(afterScreenUpdates: true)
        return viewCopy!
    }
}

