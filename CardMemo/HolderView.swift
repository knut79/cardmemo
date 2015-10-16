
import UIKit

protocol HolderViewDelegate:class {
    func loadScreenFinished()
}

class HolderView: UIView {

  let redRectangleLayer = RectangleLayer()
  let blueRectangleLayer = RectangleLayer()
  let arcLayer = ArcLayer()

  var parentFrame :CGRect = CGRectZero
  weak var delegate:HolderViewDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = Colors.clear
    //backgroundColor = UIColor.blueColor()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }


  func startAnimation() {

    layer.anchorPoint = CGPointMake(0.5, 0.6)



    NSTimer.scheduledTimerWithTimeInterval(0.45, target: self,
      selector: "drawRedAnimatedRectangle",
      userInfo: nil, repeats: false)
    NSTimer.scheduledTimerWithTimeInterval(0.65, target: self,
      selector: "drawBlueAnimatedRectangle",
      userInfo: nil, repeats: false)
  }

  func drawRedAnimatedRectangle() {
    layer.addSublayer(redRectangleLayer)
    redRectangleLayer.animateStrokeWithColor(Colors.red)
  }

  func drawBlueAnimatedRectangle() {
    layer.addSublayer(blueRectangleLayer)
    blueRectangleLayer.animateStrokeWithColor(Colors.white)
    NSTimer.scheduledTimerWithTimeInterval(0.40, target: self, selector: "drawArc",
      userInfo: nil, repeats: false)
  }

  func drawArc() {
    layer.addSublayer(arcLayer)
    arcLayer.animate()
    
    let dLabel = UILabel(frame: CGRectMake(0, 0, 50, 50))
    dLabel.center = CGPointMake(self.bounds.width / 2, self.bounds.height / 2)
    dLabel.textColor = UIColor.blueColor()
    dLabel.textAlignment = NSTextAlignment.Center
    dLabel.font = UIFont.boldSystemFontOfSize(40)
    dLabel.text = "D"
    
    let dLabel2 = UILabel(frame: CGRectMake(0, 0, 50, 50))
    dLabel2.center = CGPointMake(self.bounds.width / 2, self.bounds.height / 2)
    dLabel2.frame.offsetInPlace(dx: 10, dy: 10)
    dLabel2.textColor = UIColor.blueColor()
    dLabel2.textAlignment = NSTextAlignment.Center
    dLabel2.font = UIFont.boldSystemFontOfSize(40)
    dLabel2.text = "D"
    self.addSubview(dLabel)
    self.addSubview(dLabel2)
    
    NSTimer.scheduledTimerWithTimeInterval(0.90, target: self, selector: "expandView",
      userInfo: nil, repeats: false)
  }

  func expandView() {
    backgroundColor = Colors.white
    frame = CGRectMake(frame.origin.x - blueRectangleLayer.lineWidth,
      frame.origin.y - blueRectangleLayer.lineWidth,
      frame.size.width + blueRectangleLayer.lineWidth * 2,
      frame.size.height + blueRectangleLayer.lineWidth * 2)
    layer.sublayers = nil

    UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
      self.frame = self.parentFrame
      }, completion: { finished in
        self.finishedAnimating()
    })
  }

  func finishedAnimating() {
    delegate?.loadScreenFinished()
  }

}
