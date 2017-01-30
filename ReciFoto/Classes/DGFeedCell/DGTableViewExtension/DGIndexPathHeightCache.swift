//
//  DGIndexPathHeightCache.swift
//
//  Created by zhaodg on 11/25/15.
//  Copyright © 2015 zhaodg. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


// MARK: - DGIndexPathHeightCache
class DGIndexPathHeightCache {

    fileprivate var heights: [[CGFloat]] = []

    // Enable automatically if you're using index path driven height cache. Default is true
    internal var automaticallyInvalidateEnabled: Bool = true

    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(DGIndexPathHeightCache.deviceOrientationDidChange), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    deinit {
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }

    // MARK: - public
    subscript(indexPath: IndexPath) -> CGFloat? {
        get {
            if indexPath.section < heights.count && indexPath.row < heights[indexPath.section].count {
                return heights[indexPath.section][indexPath.row]
            }
            return nil
        }
        set {
            self.buildIndexPathIfNeeded(indexPath)
            heights[indexPath.section][indexPath.row] = newValue!
        }
    }

    internal func invalidateHeightAtIndexPath(_ indexPath: IndexPath) {
        self[indexPath] = -1
    }

    internal func invalidateAllHeightCache() {
        self.heights.removeAll()
    }

    internal func existsIndexPath(_ indexPath: IndexPath) -> Bool {
        return self[indexPath] != nil && self[indexPath] > -0.0000000001
    }

    internal func insertSections(_ sections: IndexSet) {
        (sections as NSIndexSet).enumerate({ (index, stop) -> Void in
            self.buildSectionsIfNeeded(index)
            self.heights.insert([], at: index)
        })
    }

    internal func deleteSections(_ sections: IndexSet) {
        (sections as NSIndexSet).enumerate({ (index, stop) -> Void in
            self.buildSectionsIfNeeded(index)
            self.heights.remove(at: index)
        })
    }

    internal func reloadSections(_ sections: IndexSet) {
        (sections as NSIndexSet).enumerate({ (index, stop) -> Void in
            self.buildSectionsIfNeeded(index)
            self.heights[index] = []
        })
    }

    internal func moveSection(_ section: Int, toSection newSection: Int) {
        self.buildSectionsIfNeeded(section)
        self.buildSectionsIfNeeded(newSection)
        swap(&self.heights[section], &self.heights[newSection])
    }

    internal func insertRowsAtIndexPaths(_ indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            self.buildIndexPathIfNeeded(indexPath)
            self.heights[indexPath.section].insert(-1, at: indexPath.row)
        }
    }

    internal func deleteRowsAtIndexPaths(_ indexPaths: [IndexPath]) {
        let indexPathSorted = indexPaths.sorted { $0.section > $1.section || $0.row > $1.row }
        for indexPath in indexPathSorted {
            self.buildIndexPathIfNeeded(indexPath)
            self.heights[indexPath.section].remove(at: indexPath.row)
        }
    }

    internal func reloadRowsAtIndexPaths(_ indexPaths: [IndexPath]) {
        for indexPath in indexPaths {
            self.buildIndexPathIfNeeded(indexPath)
            self.invalidateHeightAtIndexPath(indexPath)
        }
    }

    internal func moveRowAtIndexPath(_ indexPath: IndexPath, toIndexPath newIndexPath: IndexPath) {
        self.buildIndexPathIfNeeded(indexPath)
        self.buildIndexPathIfNeeded(newIndexPath)
        swap(&self.heights[indexPath.section][indexPath.row], &self.heights[indexPath.section][indexPath.row])
    }

    // MARK: - private 
    fileprivate func buildSectionsIfNeeded(_ targetSection: Int) {
        if targetSection >= heights.count {
            for _ in heights.count...targetSection {
                self.heights.append([])
            }
        }
    }

    fileprivate func buildRowsIfNeeded(_ targetRow: Int, existSextion: Int) {
        if existSextion < heights.count && targetRow >= heights[existSextion].count {
            for _ in heights[existSextion].count...targetRow {
                self.heights[existSextion].append(-1)
            }
        }
    }

    fileprivate func buildIndexPathIfNeeded(_ indexPath: IndexPath) {
        self.buildSectionsIfNeeded(indexPath.section)
        self.buildRowsIfNeeded(indexPath.row, existSextion: indexPath.section)
    }

    @objc fileprivate func deviceOrientationDidChange() {
        self.invalidateAllHeightCache()
    }
}

// MARK: - UITableView Extension
extension UITableView {

    fileprivate struct AssociatedKey {
        static var DGIndexPathHeightCache = "DGIndexPathHeightCache"
    }

    /// Height cache by index path. Generally, you don't need to use it directly.
    internal var dg_indexPathHeightCache: DGIndexPathHeightCache {
        if let value: DGIndexPathHeightCache = objc_getAssociatedObject(self, &AssociatedKey.DGIndexPathHeightCache) as? DGIndexPathHeightCache {
            return value
        } else {
            let cache: DGIndexPathHeightCache = DGIndexPathHeightCache()
            objc_setAssociatedObject(self, &AssociatedKey.DGIndexPathHeightCache, cache, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return cache
        }
    }
}
