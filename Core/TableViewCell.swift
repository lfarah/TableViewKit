//
//  TableViewCell.swift
//  TableViewKit
//
//  Created by Nelson Dominguez Leon on 08/06/16.
//  Copyright © 2016 ODIGEO. All rights reserved.
//

import Foundation
import UIKit

public enum TableViewCellPosition {
    case First, Middle, Last, Single, Any
}

public enum TableViewCellType {
    
    case Nib(UINib, UITableViewCell.Type)
    case Class(UITableViewCell.Type)
    
    public var reusableIdentifier: String {
        switch self {
        case .Class(let cellClass):
            return String(cellClass)
        case .Nib(_, let cellClass):
            return String(cellClass)
        }
    }
    
    public var cellClass: UITableViewCell.Type {
        switch self {
        case .Class(let cellClass):
            return cellClass
        case .Nib(_, let cellClass):
            return cellClass
        }
    }
}

public class TableViewCell : UITableViewCell {
    
    // MARK: Public
    
    weak public var tableViewManager: TableViewManager!
    
    public var responder: UIResponder?
    
    public var actionBar: ActionBar!
    
    public var item: TableViewItemProtocol?
    
    public var type: TableViewCellPosition {
        let rowIndex = item?.indexPath?.row
        if rowIndex == 0 && item?.section?.items.count == 1 { return .Single }
        if rowIndex == 0 && item?.section?.items.count > 1 { return .First }
        if rowIndex > 0 && rowIndex < (item?.section?.items.count)! - 1 && item?.section?.items.count > 2 { return .Middle }
        if rowIndex == (item?.section?.items.count)! - 1 && (item?.section?.items.count)! > 1 { return .Last }
        return .Any
    }
    
    // MARK: Constructors
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override required init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }
    
    // MARK: Configure
    
    public func commonInit() {
        
        actionBar = ActionBar(delegate: self)
    }

}

extension TableViewCell: ActionBarDelegate {
    
    private func indexPathForPreviousResponderInSectionIndex(sectionIndex: Int) -> NSIndexPath? {
        
        let section = tableViewManager.sections[sectionIndex]
        let indexInSection = section == item!.section ? section.items.indexOf { $0 == item! } : section.items.count
        
        guard indexInSection > 0 else { return nil }
            
        for itemIndex in (0 ..< indexInSection!).reverse() {
            let previousItem = section.items[itemIndex]
            let cell = previousItem.drawer.cell(forTableView: tableViewManager.tableView, atIndexPath: previousItem.indexPath!)
            if cell.responder != nil {
                return previousItem.indexPath
            }
        }
        
        return nil
    }
    
    private func indexPathForPreviousResponder() -> NSIndexPath? {
        let sectionIndex = (item?.indexPath?.section)!

        for index in (0 ... sectionIndex).reverse() {
            if let indexPath = indexPathForPreviousResponderInSectionIndex(index) {
                return indexPath
            }
        }
        
        return nil
    }
    
    private func indexPathForNextResponderInSectionIndex(sectionIndex: Int) -> NSIndexPath? {
        
        let section = tableViewManager.sections[sectionIndex]
        let indexInSection = section == item!.section ? section.items.indexOf { $0 == item! } : -1
        
        for itemIndex in indexInSection! + 1 ..< section.items.count {
            let nextItem = section.items[itemIndex]
            let cell = nextItem.drawer.cell(forTableView: tableViewManager.tableView, atIndexPath: nextItem.indexPath!)
            if cell.responder != nil {
                return nextItem.indexPath
            }
        }
        
        return nil
    }
    
    private func indexPathForNextResponder() -> NSIndexPath? {
        let sectionIndex = (item?.indexPath?.section)!

        for index in sectionIndex ... tableViewManager.sections.count - 1 {
            if let indexPath = indexPathForNextResponderInSectionIndex(index) {
                return indexPath
            }
        }
        
        return nil
    }
    
    private func indexPathForResponder(forDirection direction: Direction) -> NSIndexPath? {
        
        switch direction {
        case .next:
            return indexPathForNextResponder()
        case .previous:
            return indexPathForPreviousResponder()
        }
    }
    
    public func actionBar(actionBar: ActionBar, direction direction: Direction) {
        
        guard let indexPath = indexPathForResponder(forDirection: direction) else { return }
        
        tableViewManager.tableView .scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: false)
        
        var cell = tableViewManager.tableView.cellForRowAtIndexPath(indexPath) as? TableViewCell
        cell?.responder?.becomeFirstResponder()
    }
    
    public func actionBar(actionBar: ActionBar, doneButtonPressed doneButtonItem: UIBarButtonItem) {
        endEditing(true)
    }
}



