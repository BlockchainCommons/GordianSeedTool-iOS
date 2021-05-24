//
//  UndoStack.swift
//  Guardian
//
//  Created by Wolf McNally on 5/22/21.
//

import SwiftUI

class UndoStack: ObservableObject {
    @Published var canUndo = false
    @Published var canRedo = false
    
    private var undoActions: [Action] = [] {
        didSet {
            self.canUndo = !self.undoActions.isEmpty
        }
    }
    
    private var redoActions: [Action] = [] {
        didSet {
            self.canRedo = !self.redoActions.isEmpty
        }
    }
    
    func perform(_ action: @escaping () -> Void, undo: @escaping () -> Void) {
        redoActions.removeAll()
        action()
        undoActions.append(Action(undo: undo, redo: action))
    }
    
    func push(_ action: @escaping () -> Void, undo: @escaping () -> Void) {
        redoActions.removeAll()
        undoActions.append(Action(undo: undo, redo: action))
    }

    func undo() {
        guard let item = undoActions.popLast() else {
            return
        }

        DispatchQueue.main.async {
            item.undo()
        }
        
        redoActions.append(item)
    }
    
    func redo() {
        guard let item = redoActions.popLast() else {
            return
        }
        
        DispatchQueue.main.async {
            item.redo()
        }
        
        undoActions.append(item)
    }
    
    func invalidate() {
        undoActions.removeAll()
        redoActions.removeAll()
    }

    struct Action {
        let undo: () -> Void
        let redo: () -> Void
        
        init(undo: @escaping () -> Void, redo: @escaping () -> Void) {
            self.undo = undo
            self.redo = redo
        }
    }
}
