//
//  PlanningCellProtocol.swift
//  Epintra
//
//  Created by Maxime Junger on 30/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import Foundation

protocol PlanningCellProtocol: class {
    func tappedCell(withEvent event: Planning)
    func tappedCell(withSlot slot: Slot)
}
