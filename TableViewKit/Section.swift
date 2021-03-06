//
//  TableViewSection.swift
//  TableViewKit
//
//  Created by Nelson Dominguez Leon on 07/06/16.
//  Copyright © 2016 ODIGEO. All rights reserved.
//

import Foundation
import UIKit

/// A type that represent a section to be displayed
/// containing `items`, a `header` and a `footer`
public protocol Section: class {
    
    /// A array containing the `items` of the section
    var items: ObservableArray<Item> { get set }

    /// The `header` of the section, none if not defined
    /// - Default: none
    var header: HeaderFooterView { get }
    /// The `footer` of the section, none if not defined
    var footer: HeaderFooterView { get }
}

extension Section {
    public var header: HeaderFooterView { return nil }
    public var footer: HeaderFooterView { return nil }
}

extension Section {
    
    /// Returns the `index` of the `section` in the specified `manager`
    ///
    /// - parameter manager: A `manager` where the `section` may have been added
    ///
    /// - returns: The `index` of the `section` or `nil` if not present
    public func index(in manager: TableViewManager) -> Int? {
        return manager.sections.index(of: self)
    }
    
    /// Register the section in the specified manager
    ///
    /// - parameter manager: A manager where the section may have been added
    internal func register(in manager: TableViewManager) {
        if case .view(let header) = header {
            manager.tableView.register(header.drawer.type)
        }
        if case .view(let footer) = footer {
            manager.tableView.register(footer.drawer.type)
        }
        items.forEach {
            manager.tableView.register($0.drawer.type)
        }
    }

    /// Setup the section internals
    ///
    /// - parameter manager: A manager where the section may have been added
    internal func setup(in manager: TableViewManager) {
        items.callback = { change in
            
            guard let sectionIndex = manager.sections.index(of: self) else { return }
            let tableView = manager.tableView

            switch change {
            case .inserts(let array):
                let indexPaths = array.map { IndexPath(item: $0, section: sectionIndex) }
                tableView.insertRows(at: indexPaths, with: .automatic)
            case .deletes(let array):
                let indexPaths = array.map { IndexPath(item: $0, section: sectionIndex) }
                tableView.deleteRows(at: indexPaths, with: .automatic)
            case .updates(let array):
                let indexPaths = array.map { IndexPath(item: $0, section: sectionIndex) }
                tableView.reloadRows(at: indexPaths, with: .automatic)
            case .moves(let array):
                let fromIndexPaths = array.map { IndexPath(item: $0.0, section: sectionIndex) }
                let toIndexPaths = array.map { IndexPath(item: $0.1, section: sectionIndex) }
                tableView.moveRows(at: fromIndexPaths, to: toIndexPaths)
            case .beginUpdates:
                tableView.beginUpdates()
            case .endUpdates:
                tableView.endUpdates()
            }

        }
    }
}

public extension Collection where Iterator.Element == Section {
    func index(of element: Iterator.Element) -> Index? {
        return index(where: { $0 === element })
    }
}
