# SPUndoManager

SPUndoManager is a subclass of NSUndoManager written in Swift that tries to take advantage of new Swift features such as closures, tuples and generic functions.

SPUndoManager is closure based, where undo operations are stored as a sequence of actions. Every action has a backwards and forwards operation.


## Setup

All you need to do to use SPUndoManger is add the following in your document class, in the init() method or wherever you feel most appropriate:

```swift
self.undoManager = SPUndoManager()
```


## Basic Usage

The most basic usage of the undo manager is to do the following:

```swift
SPUndoManagerGet()?.registerChange(
    description: "My Change", // Menu will display "Undo My Change" 
    forwards: {
        // Code to (re)do
    },
    backwards: {
        // Code to undo
    }
)
```

If you haven't already made the change, this registerChange function returns the forwards function, which you can call to make the initial change. One reason you might not want to call forwards is if the change has already taken place (in a didSet block for example), so whichever way is left up to you.

*SPUndoManagerGet() simply retreives the shared document undo manager and casts to an SPUndoManager. It is optional because the document controller provides it as an optional value. However you can create your own wrapper function that unwraps it every time if you wish.*


## Undoables

Things can get a bit more interesting with Undoables. An undoable is a struct that provides an operation to undo some change, which once undone, returns an Undoable that reverts that further change. If that didn't make any sense, the forwards operation returns the backwards operation, and vice versa.

For example, if you had two funtions such as the following in a model class: 

```swift
func insertData(data: Data) {
    // Code to make change
}

func removeData(data: Data) {
    // Code to make change
}
```

You could make this small change to have them support undo and redo:

```swift
func insertData(data: Data) {
    // Code to make change
    
    Undoable(description: "Insert Data", undo: {
        self.removeData(data);
    }).registerUndo();
}

func removeData(data: Data) {
    // Code to make change
    
    Undoable(description: "Remove Data", undo: {
        self.insertData(data);
    }).registerUndo();
}
```

Undoables can also be returned from functions to give the caller the option of registering the undo or not. This may be useful for testing, or for setting up initial testing state, or for making it clear to the caller that the function does some operation which changes the state of model.

```swift
func insertData(data: Data) -> Undoable {
    // Code to make change
    
    return Undoable(description: "Insert Data", undo: {
        self.removeData(data);
    });
}

func removeData(data: Data) -> Undoable {
    // Code to make change
    
    return Undoable(description: "Remove Data", undo: {
        self.insertData(data);
    });
}
```

Utility functions are also provided if you wish to return another value from a function which also returns an undoable. For example:

```swift
// Returns tuple with undoable as last parameter
func insertData(data: Data) -> (dataCount: Int, Undoable) {
    // Code to make change
    
    return (dataCount, Undoable(description: "Insert Data", undo: {
        self.removeData(data);
    }));
}

let howMuchDataTho = registerUndo(insertData(myData));
// or
let howMuchDataTho = ignoreUndo(insertData(myData));
```

## Nesting/Grouping

I love a good nest. SPUndoManager supports nesting of undo operations with the following global functions for convenience, as well as member functions of the manager: 

```swift
// Groups all actions registered within the closure
groupUndoActions(description: String, closure: () -> ())
```

```swift
// Groups all actions in closure, but cancels if returns false
groupUndoActions(description: String, closure: () -> Bool)
```



##### Or use the more freeform style grouping functions:
* beginUndoGrouping(description: String)
* endUndoGrouping()
* cancelUndoGrouping()


Grouping can be useful for coalescing a bunch of small changes into one larger change. As an example, dragging the mouse across the screen to move an object changes the value in tiny increments, but you would want to undo the movement in larger amounts.

It can also be useful for hiding lower level changes behind higher level abstractions. For example, to create a image, I initialise an image and set every pixel one by one until the image is complete. If we undo this, we expect the image to disappear, not the very last pixel that was changed.


### cancelUndoGrouping()

Cancelling an undo group removes all operations since the start of the last undo group and removes the start of it as well. This is useful if you start recording the actions for an undo but find out further down the line that you can't perform the actions to complete it. Rather than have an incomplete undo group, you can just cancel the whole thing.


## Memory Management

Unless you use [weak self] or [unowned self] in closures, they will retain the objects that are passed in. The effect that this will have is that objects that you 'remove' from your model will stick around in memory until the maximum number of undo steps is reached and old values start getting cleared out.

To me, it does makes sense to retain the objects. If you want to get back the exact object you deleted, then why not. Not only that, but previous undo steps could refer to that exact object reference and risk becoming invalid if a new one was created. If I'm really wrong about this, let me know. 


## Feedback

Feel free to submit an issue or pull request if you have any trouble with anything.
