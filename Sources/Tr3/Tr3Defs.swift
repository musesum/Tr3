//
//  Tr3Defs.swift
//
//  Created by warren on 3/12/19.
//  Copyright © 2019 DeepMuse
//  License: Apache 2.0 - see License file

import Foundation
import Par

// Tr3
public typealias Tr3Visitor = ((Tr3,Visitor)->())
public typealias Tr3PriorParItem = ((Tr3,String,ParItem,Int)->(Tr3))
