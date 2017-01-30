//
//  DGKeyedHeightCache.swift
//
//  Created by zhaodg on 11/25/15.
//  Copyright © 2015 zhaodg. All rights reserved.
//

import UIKit

// MARK: - DGHeightsDictionary
class DGHeightsDictionary {

    fileprivate var heights: [String: CGFloat] = [:]

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(DGHeightsDictionary.deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    // MARK: - public
    subscript(key: String) -> CGFloat? {
        get {
            return heights[key]
        }
        set {
            heights[key] = newValue
        }
    }

    internal func invalidateHeightForKey(_ key: String) -> CGFloat? {
        return self.heights.removeValue(forKey: key)
    }

    internal func invalidateAllHeightCache() {
        return self.heights.removeAll()
    }

    internal func existsKey(_ key: String) -> Bool {
        return self[key] != nil
    }

    // MARK: - private
    @objc fileprivate func deviceOrientationDidChange() {
        self.invalidateAllHeightCache()
    }
}

// MARK: - UITableView Extension
extension UITableView {
    
    fileprivate struct AssociatedKey {
        static var DGkeyedHeightCache = "DGkeyedHeightCache"
    }

    /// Height cache by key. Generally, you don't need to use it directly.
    internal var dg_keyedHeightCache: DGHeightsDictionary {
        if let value: DGHeightsDictionary = objc_getAssociatedObject(self, &AssociatedKey.DGkeyedHeightCache) as? DGHeightsDictionary {
            return value
        } else {
            let cache: DGHeightsDictionary = DGHeightsDictionary()
            objc_setAssociatedObject(self, &AssociatedKey.DGkeyedHeightCache, cache, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return cache
        }
    }
}
