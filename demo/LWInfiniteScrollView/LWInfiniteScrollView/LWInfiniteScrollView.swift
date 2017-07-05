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

    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setContentView(_ view: UIView) {
        if self.subviews.count != 0 {
            self.subviews[0].removeFromSuperview()
        }
        view.frame.origin = CGPoint(x: 0, y: 0)
        self.addSubview(view)
    }
}

open class LWInfiniteScrollView: UIView {

    var contentScrollView: UIScrollView!
    var leftView: LWInfiniteView?
    var middleView: LWInfiniteView?
    var rightView: LWInfiniteView?
    var viewsArray = [LWInfiniteView?]()
    
    var dataArray = [UIView]()
    
    //左中右，初始化总在中间 page = 1
    var lastPage = 1
    
    //初始化总是显示index = 0 的view
    var selectedViewIndex = 0
    
    var pageControl: UIPageControl!
    
    var timer: Timer!
    
    init(frame: CGRect, viewsArray: Array<UIView>) {
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
                    leftView?.setContentView(self.dataArray[1])
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
            
            viewsArray[0]?.setContentView(self.dataArray[self.leftIndex()])
            
        case .right://手向左滑动
            let movedView = viewsArray.removeFirst()
            viewsArray.append(movedView)
            
            viewsArray[0]?.frame.origin.x = 0
            viewsArray[1]?.frame.origin.x = contentScrollView.frame.size.width
            viewsArray[2]?.frame.origin.x = contentScrollView.frame.size.width * 2
            
            viewsArray[2]?.setContentView(self.dataArray[self.rightIndex()])
            
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
        contentScrollView.setContentOffset(CGPoint(x: contentScrollView.frame.size.width, y: 0), animated: true)
        self.middleIndex(afterMove: .right)
        moveViewAtIndexes([2], direction: .right)
        
        contentScrollView.setContentOffset(CGPoint(x: contentScrollView.frame.size.width, y: 0), animated: false)
        
        lastPage = 1
        pageControl.currentPage = selectedViewIndex

    }
    
    //预留：外部调用翻页
    open func nextPatch() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(LWInfiniteScrollView.moveNextPage), userInfo: nil, repeats: true)
        moveNextPage()
    }

}
extension LWInfiniteScrollView: UIScrollViewDelegate {
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollView.isUserInteractionEnabled = false
        
        timer.invalidate()
    }
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        scrollView.isUserInteractionEnabled = true
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
