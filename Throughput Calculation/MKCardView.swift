//  Created by Avinav Goel on 22/02/16.
//  Copyright © 2016 Avinav Goel. All rights reserved.


import UIKit

@IBDesignable
public class MKCardView: UIControl {

    @IBInspectable public var elevation: CGFloat = 2 {
        didSet {
            mkLayer.elevation = elevation
        }
    }
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            mkLayer.superLayerDidResize()
        }
    }
    @IBInspectable public var shadowOffset: CGSize = .zero {
        didSet {
            mkLayer.shadowOffset = shadowOffset
        }
    }
	@IBInspectable public var roundingCorners: UIRectCorner = UIRectCorner.allCorners {
        didSet {
            mkLayer.roundingCorners = roundingCorners
        }
    }
    @IBInspectable public var maskEnabled: Bool = true {
        didSet {
            mkLayer.maskEnabled = maskEnabled
        }
    }
    @IBInspectable public var rippleScaleRatio: CGFloat = 1.0 {
        didSet {
            mkLayer.rippleScaleRatio = rippleScaleRatio
        }
    }
    @IBInspectable public var rippleDuration: CFTimeInterval = 0.35 {
        didSet {
            mkLayer.rippleDuration = rippleDuration
        }
    }
    @IBInspectable public var rippleEnabled: Bool = true {
        didSet {
            mkLayer.rippleEnabled = rippleEnabled
        }
    }
    @IBInspectable public var rippleLayerColor: UIColor = UIColor(hex: 0xEEEEEE) {
        didSet {
			mkLayer.setRippleColor(color: rippleLayerColor)
        }
    }
    @IBInspectable public var backgroundAnimationEnabled: Bool = true {
        didSet {
            mkLayer.backgroundAnimationEnabled = backgroundAnimationEnabled
        }
    }

    override public var bounds: CGRect {
        didSet {
            mkLayer.superLayerDidResize()
        }
    }

    public lazy var mkLayer: MKLayer = MKLayer(withView: self)

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }

    private func setupLayer() {
        mkLayer.elevation = self.elevation
        self.layer.cornerRadius = self.cornerRadius
        mkLayer.elevationOffset = self.shadowOffset
        mkLayer.roundingCorners = self.roundingCorners
        mkLayer.maskEnabled = self.maskEnabled
        mkLayer.rippleScaleRatio = self.rippleScaleRatio
        mkLayer.rippleDuration = self.rippleDuration
        mkLayer.rippleEnabled = self.rippleEnabled
        mkLayer.backgroundAnimationEnabled = self.backgroundAnimationEnabled
		mkLayer.setRippleColor(color: self.rippleLayerColor)
		mkLayer.shadowColor = UIColor.lightGray.cgColor
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
		mkLayer.touchesBegan(touches: touches, withEvent: event)
    }

	public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		mkLayer.touchesEnded(touches: touches, withEvent: event)
    }

	public override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
		super.touchesCancelled(touches!, with: event)
		mkLayer.touchesCancelled(touches: touches, withEvent: event)
    }

	public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		mkLayer.touchesMoved(touches: touches, withEvent: event)
    }
}
