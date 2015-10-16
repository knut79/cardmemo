//
//  TestMemoryViewController.swift
//  CardMemo
//
//  Created by knut on 24/03/15.
//  Copyright (c) 2015 knut. All rights reserved.
//
import Foundation
import UIKit
import CoreData
import iAd

class TestMemoryViewController: UIViewController, ADBannerViewDelegate{
    

    var fourButton: UIButton!
    var twoButton: UIButton!
    var threeButton: UIButton!
    var fiveButton: UIButton!
    var sixButton: UIButton!
    var sevenButton: UIButton!
    var eightButton: UIButton!
     var nineButton: UIButton!
    var tenButton: UIButton!
    var jacksButton: UIButton!
    var queenButton: UIButton!
    var kingButton: UIButton!
    var acesButton: UIButton!
    var hartsButton: UIButton!
    var diamondsButton: UIButton!
    var spadesButton: UIButton!
    var clubsButton: UIButton!
    var cardBacksideView: UIView!
    
    var cardView: UIImageView!
    
    //♤ ♡ ♢ ♧
    //♠ ♥ ♣ ♦
    
    var cardsToMemorize:Array<Card> = Array<Card>()
    var suite = "H"
    var currentCardIndex:Int = 0
    var numRightCards = 0
    var numWrongCards = 0
    var currentRightCard = false
    var wrongCards:[UIImageView] = []
    var rightCards:[UIImageView] = []
    var bannerView:ADBannerView?
    
    enum gameStateEnum:Int{
        case won = 1 ,lost ,running
    }
    var gameState:gameStateEnum = gameStateEnum.running
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Now that the view loaded, we have a frame for the view, which will be (0,0,screen width, screen height)
        // This is a good size for the table view as well, so let's use that
        // The only adjust we'll make is to move it down by 20 pixels, and reduce the size by 20 pixels
        // in order to account for the status bar
        
        self.canDisplayBannerAds = true
        bannerView = ADBannerView(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 44, UIScreen.mainScreen().bounds.size.width, 44))
        self.view.addSubview(bannerView!)
        self.bannerView?.delegate = self
        self.bannerView?.hidden = false
        
        // Store the full frame in a temporary variable
        var viewFrame = self.view.frame
        
        // Adjust it down by 20 points
        viewFrame.origin.y += 20
        
        
        
        setupButtons()
        
        enableValueButtons(false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func setupButtons()
    {
        
        let marginSides:CGFloat = UIScreen.mainScreen().bounds.size.width * 0.1
        let marginBetween:CGFloat = UIScreen.mainScreen().bounds.size.width * 0.05
        
        
        //let buttonWidthBasedOnHeight = (UIScreen.mainScreen().bounds.size.height - self.navigationController!.navigationBar.frame.height - (marginBetween * 7) - marginTop ) / 7
        let buttonWidthBasedOnWidth = (UIScreen.mainScreen().bounds.size.width - (marginSides * 2) - (marginBetween * 3)) / 4
        
        let buttonWidth = buttonWidthBasedOnWidth // buttonWidthBasedOnWidth < buttonWidthBasedOnHeight ? buttonWidthBasedOnWidth : buttonWidthBasedOnHeight
        let buttonHeight = buttonWidth
        
        let marginTop:CGFloat = self.navigationController!.navigationBar.frame.height + (buttonHeight * 2)
        
        hartsButton = PictureButton(frame: CGRectMake(marginSides, marginTop, buttonHeight, buttonHeight),image: "hearts.png")
        hartsButton.addTarget(self, action: "suiteButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        diamondsButton = PictureButton(frame: CGRectMake(hartsButton.frame.maxX + marginBetween, hartsButton.frame.minY, buttonHeight, buttonHeight),image: "diamonds.png")
        diamondsButton.addTarget(self, action: "suiteButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        spadesButton = PictureButton(frame: CGRectMake(diamondsButton.frame.maxX + marginBetween, hartsButton.frame.minY, buttonHeight, buttonHeight),image:"spadesInvert.png")
        spadesButton.addTarget(self, action: "suiteButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        clubsButton = PictureButton(frame: CGRectMake(spadesButton.frame.maxX + marginBetween, hartsButton.frame.minY, buttonHeight, buttonHeight),image: "clubsInvert")
        clubsButton.addTarget(self, action: "suiteButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        
        jacksButton = PictureButton(frame: CGRectMake(marginSides, marginTop, buttonHeight, buttonHeight),image: "jacks.png")
        jacksButton.addTarget(self, action: "valueButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        queenButton = PictureButton(frame: CGRectMake(jacksButton.frame.maxX + marginBetween, jacksButton.frame.minY, buttonHeight, buttonHeight),image: "queen.png")
        queenButton.addTarget(self, action: "valueButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        kingButton = PictureButton(frame: CGRectMake(queenButton.frame.maxX + marginBetween, jacksButton.frame.minY, buttonHeight, buttonHeight),image: "king.png")
        kingButton.addTarget(self, action: "valueButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        acesButton = NumberButton(frame: CGRectMake(kingButton.frame.maxX + marginBetween, jacksButton.frame.minY, buttonHeight, buttonHeight))
        acesButton.setTitle("A", forState: UIControlState.Normal)
        acesButton.addTarget(self, action: "valueButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        eightButton = NumberButton(frame: CGRectMake(marginSides, jacksButton.frame.maxY + marginBetween, buttonHeight, buttonHeight))
        eightButton.setTitle("8", forState: UIControlState.Normal)
        eightButton.addTarget(self, action: "valueButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        nineButton = NumberButton(frame: CGRectMake(eightButton.frame.maxX + marginBetween, eightButton.frame.minY, buttonHeight, buttonHeight))
        nineButton.setTitle("9", forState: UIControlState.Normal)
        nineButton.addTarget(self, action: "valueButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        tenButton = NumberButton(frame: CGRectMake(nineButton.frame.maxX + marginBetween, eightButton.frame.minY, buttonHeight, buttonHeight))
        tenButton.setTitle("10", forState: UIControlState.Normal)
        tenButton.addTarget(self, action: "valueButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        fiveButton = NumberButton(frame: CGRectMake(marginSides, eightButton.frame.maxY + marginBetween, buttonHeight, buttonHeight))
        fiveButton.setTitle("5", forState: UIControlState.Normal)
        fiveButton.addTarget(self, action: "valueButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        sixButton = NumberButton(frame: CGRectMake(fiveButton.frame.maxX + marginBetween, fiveButton.frame.minY, buttonHeight, buttonHeight))
        sixButton.setTitle("6", forState: UIControlState.Normal)
        sixButton.addTarget(self, action: "valueButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        sevenButton = NumberButton(frame: CGRectMake(sixButton.frame.maxX + marginBetween, fiveButton.frame.minY, buttonHeight, buttonHeight))
        sevenButton.setTitle("7", forState: UIControlState.Normal)
        sevenButton.addTarget(self, action: "valueButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        twoButton = NumberButton(frame: CGRectMake(marginSides, fiveButton.frame.maxY + marginBetween, buttonHeight, buttonHeight))
        twoButton.setTitle("2", forState: UIControlState.Normal)
        twoButton.addTarget(self, action: "valueButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        threeButton = NumberButton(frame: CGRectMake(twoButton.frame.maxX + marginBetween, twoButton.frame.minY, buttonHeight, buttonHeight))
        threeButton.setTitle("3", forState: UIControlState.Normal)
        threeButton.addTarget(self, action: "valueButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)
        fourButton = NumberButton(frame: CGRectMake(threeButton.frame.maxX + marginBetween, twoButton.frame.minY, buttonHeight, buttonHeight))
        fourButton.setTitle("4", forState: UIControlState.Normal)
        fourButton.addTarget(self, action: "valueButtonPushed:", forControlEvents: UIControlEvents.TouchUpInside)

        self.view.addSubview(hartsButton)
        self.view.addSubview(diamondsButton)
        self.view.addSubview(spadesButton)
        self.view.addSubview(clubsButton)
        
        self.view.addSubview(jacksButton)
        self.view.addSubview(queenButton)
        self.view.addSubview(kingButton)
        self.view.addSubview(acesButton)
        
        self.view.addSubview(eightButton)
        self.view.addSubview(nineButton)
        self.view.addSubview(tenButton)
        
        self.view.addSubview(fiveButton)
        self.view.addSubview(sixButton)
        self.view.addSubview(sevenButton)
        
        self.view.addSubview(twoButton)
        self.view.addSubview(threeButton)
        self.view.addSubview(fourButton)
        
        
        let image = UIImage(named: "back.png")
        cardView = UIImageView(image: image)
        //226x314
        let withToHeightCardRatio:CGFloat = 314 / 226
        cardView.frame = CGRectMake(tenButton.frame.maxX + marginBetween, tenButton.frame.minY, buttonWidth * 1.2, (buttonWidth * 1.2) * withToHeightCardRatio)
        cardView.layer.borderColor = UIColor.blackColor().CGColor
        cardView.layer.borderWidth = 1
        cardView.layer.cornerRadius = 5
        cardView.layer.masksToBounds = true
        self.view.addSubview(cardView)
        
        cardBacksideView =  UIView(frame: CGRectMake(tenButton.frame.maxX + marginBetween, tenButton.frame.minY, buttonWidth * 1.2, (buttonWidth * 1.2) * withToHeightCardRatio))
        cardBacksideView.layer.borderColor = UIColor.blackColor().CGColor
        cardBacksideView.layer.borderWidth = 1
        cardBacksideView.layer.cornerRadius = 5
        cardBacksideView.layer.masksToBounds = true
        self.view.addSubview(cardBacksideView)
        
        if let banner = self.bannerView
        {
            if fourButton.frame.maxY > banner.frame.minY
            {
                banner.hidden = true
                banner.frame.offsetInPlace(dx: 0, dy: banner.frame.height)
            }
        }

    }
    
    func valueButtonPushed(sender: UIButton) {
        
        var imageName:String!
        var cardName:String!
        switch sender
        {
        case twoButton:
            cardName = "2" + suite
        case threeButton:
            cardName = "3" + suite
        case fourButton:
            cardName = "4" + suite
        case fiveButton:
            cardName = "5" + suite
        case sixButton:
            cardName = "6" + suite
        case sevenButton:
            cardName = "7" + suite
        case eightButton:
            cardName = "8" + suite
        case nineButton:
            cardName = "9" + suite
        case tenButton:
            cardName = "10" + suite
        case jacksButton:
            cardName = "J" + suite
        case queenButton:
            cardName = "Q" + suite
        case kingButton:
            cardName = "K" + suite
        case acesButton:
            cardName = "A" + suite
        default:
            cardName = "NO!"
            print("could not find card value")
        }
        imageName = cardName + ".png"
        
        if let image = UIImage(named: imageName)
        {
            cardView.image = imageResize(image,sizeChange: CGSizeMake(cardView.frame.width ,cardView.frame.height))
        }
        
        //if right card. span a new imageview and place it at top
        let cardToPush: UIImageView = UIImageView(image: cardView.image)
        //cardvaluePadView
        cardToPush.center = CGPointMake( cardBacksideView.center.x, cardBacksideView.center.y )
        view.addSubview(cardToPush)
        
        if let image = UIImage(named: "back.png")
        {
            cardView.image = imageResize(image,sizeChange: CGSizeMake(cardView.frame.width ,cardView.frame.height))
        }
        
        if cardsToMemorize[currentCardIndex].front == cardName
        {
            self.rightCards.append(cardToPush)
            self.currentRightCard = true
            self.numRightCards++
            self.currentCardIndex++
            animateCorrectCardMessage(cardsToMemorize.count - numRightCards,completionAnimation: {() -> Void in

            })

        }
        else
        {
            
            self.wrongCards.append(cardToPush)
            self.currentRightCard = false
            self.numWrongCards++
            
            animateWrongCardMessage({() -> Void in

            })
            
        }
        
        let maxNumOfVisualCardsInARow = 20
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            
            cardToPush.frame.size.height = cardToPush.frame.height * 0.7
            cardToPush.frame.size.width = cardToPush.frame.size.width * 0.7
            let marginBottom:CGFloat = UIScreen.mainScreen().bounds.size.height*0.05
            if(self.currentRightCard)
            {
                let x:CGFloat = (UIScreen.mainScreen().bounds.size.width*0.1) + (cardToPush.frame.width/2) + (CGFloat(self.numRightCards%maxNumOfVisualCardsInARow)*4)
                let y:CGFloat = self.navigationController!.navigationBar.frame.maxY + (cardToPush.frame.height / 2) + 5
                cardToPush.center = CGPoint(x: x,y: y)
            }
            else //WRONG answer
            {
                let x:CGFloat = self.cardView.center.x +  (CGFloat(self.numWrongCards%maxNumOfVisualCardsInARow)*4)
                let y:CGFloat = self.cardView.frame.maxY + (cardToPush.frame.height / 2) + marginBottom
                cardToPush.center = CGPoint(x: x,y: y)
            }
            
            }, completion: { (value: Bool) in
                if(self.numWrongCards >= 5)
                {
                    if let image = UIImage(named: "back.png")
                    {
                        for( var i = 0; i < self.wrongCards.count ; i++ )
                        {
                            self.wrongCards[i].image = image
                        }
                    }
                    self.gameState = gameStateEnum.lost
                    //todo enable all buttons, present completion message
                }
                if(self.numRightCards >= self.cardsToMemorize.count)
                {
                    if let image = UIImage(named: "back.png")
                    {
                        for( var i = 0; i < self.rightCards.count ; i++ )
                        {
                            self.rightCards[i].image = image
                        }
                    }

                    self.gameState = gameStateEnum.won
                    //todo enable all buttons , present failure message
                }
                
                self.setButtonsByGameState()
                
            })
    }
    
    func animateCorrectCardMessage(cardsLeft:Int,completionAnimation: (() -> (Void))? = nil)
    {
        
        let infoMessage = UILabel(frame: CGRectMake(100, (UIScreen.mainScreen().bounds.size.height / 2) - 50, UIScreen.mainScreen().bounds.size.width - 200, 100))
        infoMessage.font = UIFont.boldSystemFontOfSize(45)
        infoMessage.textColor = UIColor.blackColor()
        
        //infoMessage.layer.borderColor = UIColor.blackColor().CGColor
        //infoMessage.layer.borderWidth = 1
        infoMessage.layer.cornerRadius = 5
        infoMessage.layer.masksToBounds = true
        infoMessage.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        
        infoMessage.textAlignment = NSTextAlignment.Center
        infoMessage.text = cardsLeft > 0 ? "Correct😊 \(cardsLeft) to go" : "😃"
        infoMessage.adjustsFontSizeToFitWidth = true
        infoMessage.alpha = 0
        infoMessage.transform = CGAffineTransformScale(infoMessage.transform, 0.1, 0.1)
        self.view.addSubview(infoMessage)
        
        UIView.animateWithDuration(0.75, animations: { () -> Void in
            infoMessage.alpha = 1
            infoMessage.transform = CGAffineTransformIdentity
            }, completion: { (value: Bool) in
                UIView.animateWithDuration(1, animations: { () -> Void in
                    infoMessage.alpha = 0
                    infoMessage.transform = CGAffineTransformScale(infoMessage.transform, 2, 2)
                    }, completion: { (value: Bool) in
                        infoMessage.removeFromSuperview()
                        completionAnimation?()
                })
        })
    }
    
    func animateWrongCardMessage(completionAnimation: (() -> (Void))? = nil)
    {
        let infoMessage = UILabel(frame: CGRectMake(100, (UIScreen.mainScreen().bounds.size.height / 2) - 50, UIScreen.mainScreen().bounds.size.width - 200, 100))
        //infoMessage.layer.borderColor = UIColor.clearColor().CGColor
        infoMessage.font = UIFont.boldSystemFontOfSize(45)
        infoMessage.textColor = UIColor.blackColor()
        //infoMessage.layer.borderColor = UIColor.blackColor().CGColor
        //infoMessage.layer.borderWidth = 1
        infoMessage.layer.cornerRadius = 5
        infoMessage.layer.masksToBounds = true
        infoMessage.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)

        infoMessage.textAlignment = NSTextAlignment.Center
        infoMessage.text = "Wrong😞"
        infoMessage.adjustsFontSizeToFitWidth = true
        infoMessage.alpha = 0
        infoMessage.transform = CGAffineTransformScale(infoMessage.transform, 0.1, 0.1)
        self.view.addSubview(infoMessage)
        
        UIView.animateWithDuration(0.75, animations: { () -> Void in
            infoMessage.alpha = 1
            infoMessage.transform = CGAffineTransformIdentity
            }, completion: { (value: Bool) in
                UIView.animateWithDuration(0.55, animations: { () -> Void in
                    infoMessage.alpha = 0
                    infoMessage.transform = CGAffineTransformScale(infoMessage.transform, 2, 2)
                    }, completion: { (value: Bool) in
                        infoMessage.removeFromSuperview()
                        completionAnimation?()
                })
        })
    }
    
    func setButtonPropertiesForGameState(button:UIButton, text:String, won:Bool = false)
    {
        button.setTitle(text, forState: .Normal)
        button.alpha = 1.0
        button.backgroundColor = won ? UIColor.greenColor() : UIColor.redColor()
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(20)
        button.titleLabel?.textColor = UIColor.blackColor()
    }
    
    func setButtonsByGameState()
    {
        switch( gameState )
        {
        case gameStateEnum.running:
            enableValueButtons(false)
            enableSuiteButtons(true)
        case gameStateEnum.lost, gameStateEnum.won:

            let label = UILabel(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height * 0.75, UIScreen.mainScreen().bounds.size.width, 100))
            label.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, (UIScreen.mainScreen().bounds.size.height / 2) - 50)
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor.blackColor()
            label.font = UIFont.boldSystemFontOfSize(50)
            label.alpha = 0
            label.text = gameState == gameStateEnum.won ? "GREAT" : "PRACTICE"
            
            self.view.addSubview(label)
            
            label.transform = CGAffineTransformScale(label.transform, 0.1, 0.1)
            
            UIView.animateWithDuration(1, animations: { () -> Void in
                label.transform = CGAffineTransformIdentity
                //label.transform = CGAffineTransformScale(label.transform, 2, 2)
                label.alpha = 1

                }, completion: { (value: Bool) in
                    let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity");
                    pulseAnimation.duration = 0.3
                    pulseAnimation.toValue = NSNumber(float: 0.3)
                    pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    pulseAnimation.autoreverses = true;
                    pulseAnimation.repeatCount = 3
                    pulseAnimation.delegate = self
                    label.layer.addAnimation(pulseAnimation, forKey: "firstLabelPulse")
                    
                    if self.gameState == gameStateEnum.won
                    {
                        
                        UIView.transitionWithView(self.cardView, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: { () -> Void in
                            
                            if let image = UIImage(named: "girl.jpg")
                            {
                                self.cardView.image = self.imageResize(image,sizeChange: CGSizeMake(self.cardView.frame.width ,self.cardView.frame.height))
                                
                            }
                            
                            
                            }, completion: { (value: Bool) in
                        })
                    
                    }
                    
            })
            
            enableValueButtons(false)
            enableSuiteButtons(false)
            
        }
        
        switch( gameState )
        {

        case gameStateEnum.won, gameStateEnum.lost:

            let label = UILabel(frame: CGRectMake(0, UIScreen.mainScreen().bounds.size.height * 0.75, UIScreen.mainScreen().bounds.size.width, 100))
            label.center = CGPointMake(UIScreen.mainScreen().bounds.size.width / 2, (UIScreen.mainScreen().bounds.size.height / 2) + 100)
            label.textAlignment = NSTextAlignment.Center
            label.textColor = UIColor.blackColor()
            label.font = UIFont.boldSystemFontOfSize(50)
            label.alpha = 0
            label.text = gameState == gameStateEnum.won ? "JOB" : "MORE"
            
            self.view.addSubview(label)
            
            label.transform = CGAffineTransformScale(label.transform, 0.1, 0.1)
            
            UIView.animateWithDuration(1, animations: { () -> Void in
                label.transform = CGAffineTransformIdentity
                //label.transform = CGAffineTransformScale(label.transform, 2, 2)
                label.alpha = 1
                
                }, completion: { (value: Bool) in
                    let pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity");
                    pulseAnimation.duration = 0.3
                    pulseAnimation.toValue = NSNumber(float: 0.3)
                    pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    pulseAnimation.autoreverses = true;
                    pulseAnimation.repeatCount = 3
                    pulseAnimation.delegate = self
                    label.layer.addAnimation(pulseAnimation, forKey: "loseLabelPulse")

            })

        default:
            break
        }
        
    }

   func suiteButtonPushed(sender: UIButton) {
        var imageName:String!
        switch sender
        {
        case spadesButton:
            imageName = "spadesWhiteBackground.png"
            suite = "S"
        case diamondsButton:
            imageName = "diamondsWhiteBackground.png"
            suite = "D"
        case hartsButton:
            imageName = "heartsWhiteBackground.png"
            suite = "H"
        case clubsButton:
            imageName = "clubsWhiteBackground.png"
            suite = "C"
        default:
            print("could not find suite")
        }
        
        if let image = UIImage(named: imageName)
        {
            UIView.transitionWithView(cardView, duration: 0.3, options: UIViewAnimationOptions.TransitionFlipFromRight, animations: { () -> Void in
                    self.cardView.image = self.imageResize(image,sizeChange: CGSizeMake(self.cardView.frame.width ,self.cardView.frame.height))
                
                }, completion: { (value: Bool) in
            })
            
            
        }
        
        enableValueButtons(true)
        enableSuiteButtons(false)
    }
    
    func imageResize (imageObj:UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        imageObj.drawInRect(CGRect(origin: CGPointZero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
    func enableSuiteButtons(value: Bool)
    {
        hartsButton.enabled = value
        spadesButton.enabled = value
        clubsButton.enabled = value
        diamondsButton.enabled = value
        
         UIView.animateWithDuration(0.3, animations: { () -> Void in
            if value
            {
                self.hartsButton.transform = CGAffineTransformIdentity
                self.spadesButton.transform = CGAffineTransformIdentity
                self.clubsButton.transform = CGAffineTransformIdentity
                self.diamondsButton.transform = CGAffineTransformIdentity
            }
            else
            {
                self.hartsButton.transform = CGAffineTransformScale(self.hartsButton.transform, 0.1, 0.1)
                self.spadesButton.transform = CGAffineTransformScale(self.spadesButton.transform, 0.1, 0.1)
                self.clubsButton.transform = CGAffineTransformScale(self.clubsButton.transform, 0.1, 0.1)
                self.diamondsButton.transform = CGAffineTransformScale(self.diamondsButton.transform, 0.1, 0.1)
            }
            self.hartsButton.alpha = value ? 1.0 : 0
            self.spadesButton.alpha = value ? 1.0 : 0
            self.clubsButton.alpha = value ? 1.0 : 0
            self.diamondsButton.alpha = value ? 1.0 : 0
            
            }, completion: { (value: Bool) in
        })

    }
    
    func enableValueButtons(value: Bool)
    {
        fourButton.enabled = value
        twoButton.enabled = value
        threeButton.enabled = value
        fiveButton.enabled = value
        sixButton.enabled = value
        sevenButton.enabled = value
        eightButton.enabled = value
        nineButton.enabled = value
        tenButton.enabled = value
        jacksButton.enabled = value
        queenButton.enabled = value
        kingButton.enabled = value
        acesButton.enabled = value
        
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            if value
            {
                self.twoButton.transform = CGAffineTransformIdentity
                self.threeButton.transform = CGAffineTransformIdentity
                self.fourButton.transform = CGAffineTransformIdentity
                self.fiveButton.transform = CGAffineTransformIdentity
                self.sixButton.transform = CGAffineTransformIdentity
                self.sevenButton.transform = CGAffineTransformIdentity
                self.eightButton.transform = CGAffineTransformIdentity
                self.nineButton.transform = CGAffineTransformIdentity
                self.tenButton.transform = CGAffineTransformIdentity
                self.jacksButton.transform = CGAffineTransformIdentity
                self.queenButton.transform = CGAffineTransformIdentity
                self.kingButton.transform = CGAffineTransformIdentity
                self.acesButton.transform = CGAffineTransformIdentity
            }
            else
            {
                self.twoButton.transform = CGAffineTransformScale(self.twoButton.transform, 0.1, 0.1)
                self.threeButton.transform = CGAffineTransformScale(self.threeButton.transform, 0.1, 0.1)
                self.fourButton.transform = CGAffineTransformScale(self.fourButton.transform, 0.1, 0.1)
                self.fiveButton.transform = CGAffineTransformScale(self.fiveButton.transform, 0.1, 0.1)
                self.sixButton.transform = CGAffineTransformScale(self.sixButton.transform, 0.1, 0.1)
                self.sevenButton.transform = CGAffineTransformScale(self.sevenButton.transform, 0.1, 0.1)
                self.eightButton.transform = CGAffineTransformScale(self.eightButton.transform, 0.1, 0.1)
                self.nineButton.transform = CGAffineTransformScale(self.nineButton.transform, 0.1, 0.1)
                self.tenButton.transform = CGAffineTransformScale(self.tenButton.transform, 0.1, 0.1)
                self.jacksButton.transform = CGAffineTransformScale(self.jacksButton.transform, 0.1, 0.1)
                self.queenButton.transform = CGAffineTransformScale(self.queenButton.transform, 0.1, 0.1)
                self.kingButton.transform = CGAffineTransformScale(self.kingButton.transform, 0.1, 0.1)
                self.acesButton.transform = CGAffineTransformScale(self.acesButton.transform, 0.1, 0.1)
            }
            self.fourButton.alpha = value ? 1.0 : 0
            self.twoButton.alpha = value ? 1.0 : 0
            self.threeButton.alpha = value ? 1.0 : 0
            self.fiveButton.alpha = value ? 1.0 : 0
            self.sixButton.alpha = value ? 1.0 : 0
            self.sevenButton.alpha = value ? 1.0 : 0
            self.eightButton.alpha = value ? 1.0 : 0
            self.nineButton.alpha = value ? 1.0 : 0
            self.tenButton.alpha = value ? 1.0 : 0
            self.jacksButton.alpha = value ? 1.0 : 0
            self.queenButton.alpha = value ? 1.0 : 0
            self.kingButton.alpha = value ? 1.0 : 0
            self.acesButton.alpha = value ? 1.0 : 0
            
            }, completion: { (value: Bool) in
        })

    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        let adFree = NSUserDefaults.standardUserDefaults().boolForKey("adFree")
        self.bannerView?.hidden = adFree
    }
    
    func bannerViewActionShouldBegin(banner: ADBannerView!, willLeaveApplication willLeave: Bool) -> Bool {
        return willLeave
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError error: NSError!) {
        self.bannerView?.hidden = true
    }
    
}