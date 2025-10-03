# Vervain Syntax Basics

This section explains the basic syntax of Vervain.

In Vervain every directive is surrounded by brackets and followed by arguments.
Here arguments may be [inline](#list-argument), [multiline](#multiline-argument) or [lists](#list-argument).

#### Inline argument
```
[directive] inline
```

#### Multiline argument
```
[directive]
multiline
multiline
multiline
```

#### List argument
```
[directive]
- list
- list
- list
```

Lists and multiline arguments are differ as only one item in a list will be choose (for example in [random](#random)), while each line in a multiline is used.

Directive can act on three different levels, [dialogue level](#dialogue-level) (metadata) [node level](#node-level) and [sequence level](#sequence-level).

## Dialogue level
Directives in this category use double brackets. They signify that a dialogue may need some special consideration.
Dialogues with ``[[Type]] stage`` for example are dialogues. which are conditioned on a stage and should thus be treated preferentially in the selection of dialogues.

### Type
`type` describes the type of the dialogue. The only functional type is the **stage** type. Dialogues of this type will be treated preferentially in the selection of dialogues.

### Import

### Node
Nodes are the central building blocks of Vervain dialogues. They store every other directive written after them this includes [node level](#node-level) and [sequence level](#sequence-level) directives. Nodes have an [inline argument](#inline-argument) which describe their name. The node named **start** is the starting point of each dialogue.

`Node` has the following syntax:
```
[[Node]] NAME
```

## Node level
Directive in this category start with a capital letter. They describe the attributes of a [node](#node) and may only appear once per [node](#node).

### Condition

### Choice

## Sequence level

### actors

### text

### jump

### goto

### random

### match

### set

### if / then / else

### action

