//
//  RecifotoProducts.swift
//  ReciFoto
//
//  Created by Colin Taylor on 2/20/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import Foundation
import StoreKit
public struct RecifotoProducts {
    static var products = [SKProduct]()
    static var boughtRecipe = Recipe()
    static let IAP_SAVE_COLLECTION_KEY = "com.perlmutter.recipe.collection"
    
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [RecifotoProducts.IAP_SAVE_COLLECTION_KEY]
    
    public static let store = IAPHelper(productIds: RecifotoProducts.productIdentifiers)
    
}

func itemNameForProductIdentifier(_ productIdentifier: String) -> Recipe? {
    return RecifotoProducts.boughtRecipe
}
func prefetchProducts(){
    RecifotoProducts.store.requestProducts{success, products in
        if success {
            RecifotoProducts.products = products!
        }
    }
}
