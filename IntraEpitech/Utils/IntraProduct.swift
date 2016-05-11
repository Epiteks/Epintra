//
//  IntraProduct.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 08/02/16.
//  Copyright © 2016 Maxime Junger. All rights reserved.
//

import Foundation

public enum IntraProduct {
	private static let Prefix = "com.maximejunger.epintra."
	
	/// MARK: - Supported Product Identifiers
	public static let Premium = Prefix + "premium"
	
	// All of the products assembled into a set of product identifiers.
	//private static let productIdentifiers: Set<ProductIdentifier> = [IntraProduct.Premium]
	
	/// Static instance of IAPHelper that for rage products.
	//public static let store = IAPHelper(productIdentifiers: IntraProduct.productIdentifiers)
}

/// Return the resourcename for the product identifier.
func resourceNameForProductIdentifier(productIdentifier: String) -> String? {
	return productIdentifier.componentsSeparatedByString(".").last
}
