import Foundation

protocol SPUndoManagerAction {
    
    var done: Bool { get }
    func undo()
    func redo()
    var description: String { get }
}

class SPUndoManagerStandardAction : SPUndoManagerAction {
    
    /// Assumes action already performed
    init(description: String, forwards: Closure, backwards: Closure) {
        
        self.forwards = forwards
        self.backwards = backwards
        self.description = description
        self.done = true
    }
    
    var done: Bool
    var backwards: Closure
    var forwards: Closure
    var description: String
    
    func undo() {
        assert(done)
        backwards()
        done = false
    }
    
    func redo() {
        assert(!done)
        forwards()
        done = true
    }
}


class SPUndoManagerSuperDynamicAction : SPUndoManagerAction {
    
    var undoable: Undoable
    var description: String
    
    /// Assumes action performed, in 'done' state by default
    init(undoable: Undoable) {
        self.undoable = undoable
        self.description = undoable.description
        self.done = true
    }
    
    var done: Bool
    func undo() {
        assert(done)
        self.undoable = undoable.undo()
        done = false
    }
    func redo() {
        assert(!done)
        self.undoable = undoable.undo()
        done = true
    }
}

class SPUndoManagerGroupAction : SPUndoManagerAction {
    
    init(description: String) {
        self.description = description
    }
    
    var done: Bool = false
    var nestedActions: [SPUndoManagerAction] = []
    
    func undo() {
        assert(done)
		for action in Array(nestedActions.reverse()) { action.undo() }
        done = false
    }
    
    func redo() {
        assert(!done)
		for action in nestedActions { action.redo() }
        done = true
    }
    
    var description: String
}