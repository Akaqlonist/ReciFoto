/**
	Copyright (C) 2015 Quentin Mathe
 
	Date:  May 2015
	License:  MIT
 */

import UIKit

@objc public protocol DropDownMenuDelegate {
	func didTapInDropDownMenuBackground(_ menu: DropDownMenu)
}

public enum DropDownMenuRevealDirection {
	case up
	case down
}


open class DropDownMenu : UIView, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {

	open weak var delegate: DropDownMenuDelegate?
    
	open var container: UIView! {
		didSet {
			removeFromSuperview()
			container.addSubview(self)
		}
	}
	// The content view fills the entire container, so we can use it to fade 
	// the background view in and out.
	//
	// By default, it contains the menu view, but other subviews can be added to 
	// it and laid out by overriding -layoutSubviews.
	open let contentView: UIView
	// This hidden offset can be used to customize the position of the menu at
	// the end of the hiding animation.
	//
	// If the container doesn't extend under the toolbar and navigation bar,
	// this is useful to ensure the hiding animation continues until the menu is
	// positioned outside of the screen, rather than stopping the animation when 
	// the menu is covered by the toolbar or navigation bar.
	open var hiddenContentOffset = CGFloat(0)
	// This visible offset can be used to customize the position of the menu 
	// at the end of the showing animation.
	//
	// If the container extends under the toolbar and navigation bar, this is 
	// useful to ensure the menu won't be covered by the toolbar or navigation 
	// bar once the showing animation is done.
	open var visibleContentOffset = CGFloat(0) {
		didSet {
			if isHidden {
				return
			}
			if direction == .down {
				contentView.frame.origin.y = visibleContentOffset
			}
			else {
				contentView.frame.origin.y = container.frame.height - contentView.frame.height - visibleContentOffset
			}
		}
	}
	open var direction = DropDownMenuRevealDirection.down
	open let menuView: UITableView
	open var menuCells = [DropDownMenuCell]() {
		didSet {
			menuView.reloadData()
		}
	}
	// The background view to be faded out with the background alpha, when the 
	// menu slides over it
	open var backgroundView: UIView? {
		didSet {
			oldValue?.removeFromSuperview()
			backgroundView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			if let backgroundView = backgroundView {
				insertSubview(backgroundView, belowSubview: contentView)
			}
		}
	}
	open var backgroundAlpha = CGFloat(1)
	
	// MARK: - Initialization
	
	override public init(frame: CGRect) {
		contentView = UIView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
		contentView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
		
		menuView = UITableView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
		menuView.autoresizingMask = .flexibleWidth
		menuView.isScrollEnabled = false

		contentView.addSubview(menuView)

		super.init(frame: frame)
		
		let gesture = UITapGestureRecognizer(target: self, action: #selector(DropDownMenu.tap(_:)))
		gesture.delegate = self
		addGestureRecognizer(gesture)

		menuView.dataSource = self
		menuView.delegate = self

		autoresizingMask = [.flexibleWidth, .flexibleHeight]
		isHidden = true

		addSubview(contentView)
	}

	required public init?(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Layout
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		menuView.sizeToFit()
		contentView.frame.size.height = menuView.frame.size.height
	}
	
	// MARK: - Actions
	
	@IBAction open func tap(_ sender: AnyObject) {
		delegate?.didTapInDropDownMenuBackground(self)
	}
	
	// If we declare a protocol method private, it is not called anymore.
	open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		precondition(gestureRecognizer.view == self)

		guard let touchedView = touch.view else {
			return true
		}
		return !touchedView.isDescendant(of: menuView)
	}
	
	@IBAction open func show() {
		precondition(container != nil, "DropDownMenu.container must be set in [presentingController viewDidAppear:]")
		
		if !isHidden {
			return
		}

		backgroundView?.alpha = 0
		if direction == .down {
			contentView.frame.origin.y = -(contentView.frame.height + hiddenContentOffset)
		}
		else {
			contentView.frame.origin.y = container.frame.height + hiddenContentOffset
		}
		isHidden = false

		UIView.animate(withDuration: 0.4,
		                    delay: 0,
		   usingSpringWithDamping: 1,
		    initialSpringVelocity: 1,
		                  options: UIViewAnimationOptions(),
		               animations: {
			if self.direction == .down {
				self.contentView.frame.origin.y = self.visibleContentOffset
			}
			else {
				self.contentView.frame.origin.y = self.container.frame.height - self.contentView.frame.height  - self.visibleContentOffset
			}
			self.backgroundView?.alpha = self.backgroundAlpha
		},
		               completion: nil)
	}
	
    @IBAction open func hide(withAnimation: Bool) {
	
		if isHidden {
			return
		}

		if direction == .down {
			contentView.frame.origin.y = visibleContentOffset
		}
		else {
			contentView.frame.origin.y = container.frame.height - contentView.frame.height - visibleContentOffset
		}
		isHidden = false
		
        var duration = 0.4
        
        if !withAnimation {
            duration = 0.0
        }
		UIView.animate(withDuration: duration,
		                    delay: 0,
		   usingSpringWithDamping: 1,
		    initialSpringVelocity: 1,
		                  options: UIViewAnimationOptions(),
		               animations: {
			if self.direction == .down {
				self.contentView.frame.origin.y = -(self.contentView.frame.height + self.hiddenContentOffset)
			}
			else {
				self.contentView.frame.origin.y = self.container.frame.height + self.hiddenContentOffset
			}
			self.backgroundView?.alpha = 0
		},
				       completion: { (Bool) in
			self.isHidden = true
		})
	}
	
    
    
    
	// MARK: - Table View
	
	open func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return menuCells.count
	}

	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return menuCells[(indexPath as NSIndexPath).row]
	}
	
	open func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return menuCells[(indexPath as NSIndexPath).row].menuAction != nil
	}

	open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let cell = menuCells[(indexPath as NSIndexPath).row]
		
		for cell in menuCells {
			cell.accessoryType = .none
		}
		cell.accessoryType = cell.showsCheckmark ? .checkmark : .none
		
		tableView.deselectRow(at: indexPath, animated: true)
		
		if cell.menuAction == nil {
			return
		}

		UIApplication.shared.sendAction(cell.menuAction, to: cell.menuTarget, from: cell, for: nil)
	}
}
