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
List arguments always start with a latent. The purpose of the latent may be different depending on the directive. In [Choice](#choice) for example it is the node name to jump to.
If on latent it self has multiline or list arguments they a tabbed in (this commonly happens in the [random](#random) directive).

```
[directive]
- [latent] list
- [latent] 
    - list
    - list
- [latent] 
    list 
    list

```

Lists and multiline arguments differ as only one item in a list will be choose (for example in [random](#random)), while each line in a multiline is used.

Directive can act on three different levels, [dialogue level](#dialogue-level) (metadata) [node level](#node-level) and [sequence level](#sequence-level).

## Dialogue level
Directives in this category use double brackets. They signify that a dialogue may need some special consideration.
Dialogues with ``[[Type]] stage`` for example are dialogues, which are conditioned on a stage and should thus be treated preferentially in the selection of dialogues.

### Type
`type` describes the type of the dialogue. The only functional type is the **stage** type. Dialogues of this type will be treated preferentially in the selection of dialogues.

### Import

### Node
Nodes are the central building blocks of Vervain dialogues. They store every other directive written after them. This includes [node level](#node-level) and [sequence level](#sequence-level) directives. Nodes have an [inline argument](#inline-argument) which describe their name.

`Node` has the following syntax:
```
[[Node]] NAME
```

The special node named **start** is the starting point of each dialogue. `[end]` ends every dialogue. Thus, each dialogue has the following frame:
```
[[Node]] start
...
[end]
```

## Node level
Directive in this category start with a capital letter. They describe the attributes of a [node](#node) and may only appear once per [node](#node).

### Condition
`Condition` describes the conditions under which the node can be jumped to by [jump](#jump). Here condition interacts directly with the game. Therefore its inline parameters are interpreted as functions calling the api to the game.
These functions calls can be nested.

```
[Condition] and_bool(npc_is_happy("Gerhard"), time_is_morning())
```

If only of of the conditions need to be true, you can use `or_bool`.

### Choice
`Choice` jumps to the next selected node. It takes list arguments, where each entries `latent` is the name of the node to jump to and `list` is the prompt the player may select.

```
[Choice]
- [NODE_NAME_1] PROMPT_1
- [end] Good bye.
```

## Sequence level
Sequence level nodes start with a lowercase letter and describe a sequence of operations in on node. Sequence level directives are executes in sequence. They include changes to the visible actors jumps to other nodes, dialogue text and more.

### actors
`actors` describes the actors currently visible, if the node has a [text](#text) directive it should always be preceded by a `actors` node (otherwise the no visible actors would have to talk, which is not possible.)
`actors` may have either inline or multiline arguments. Actors also may have additional arguments, in this case `flipped` which makes the actor look right (this literally flips the actors picture meaning characters like Friedel which look straight into the camera will continue to do so).

```
[actors]
gerhard
avatar flipped
```

```
[actors]gerhard avatar.flipped
```

`actors` can also be called during a `text` segment like this:
```
[actors]gerhard avatar.flipped
[text]
avatar:Should we swap places?
gerhard:Ok.
[actors]avatar gerhard.flipped
[text]
avatar:Whole new perspective.
gerhard:True.
```

### text
`text` describes the dialogue text. Text may have either inline or multiline, where inline arguments are treated the same as a single multiline argument.
The arguments of `text` are the name of a character followed by its text:

```
[text]
gerhard: Hello there!
avatar: Hello
```

```
[text]avatar: Hello, friend.
```

### jump
`jump` is a conditional jump to the node specified by name in its inline argument. The condition tested is the condition specified in the node to which is jumped. There also is a unconditional variant called [goto](#goto).

```
[jump] NODE_NAME
```

### goto
`goto` is a unconditional jump to the node specified by name in its inline argument. There also is a conditional variant called [jump](#jump).

```
[goto] NODE_NAME
```

### random
`random` continues the current sequence by randomly choosing one of its list arguments. Here list arguments may be any [sequence level directive](#sequence-level). Most commonly it is used or conditional jumps.

```
[random]
- [directive] ARGUMENT
- [jump] one
- [text]
    gerhard: Hello.
    avatar: hi
```

### match
`match` continues the current sequence by selecting the list argument whose latent matches the value of its inline argument.

```
[match] 5
- [1] [directive] argument
- [2] [directive]
    list
    list 
```


### set
`set` declares a dialogue local or global variable and sets its value. The first inline parameter is the name, the second is the value. The same with multiline parameters.

For a **local** variable, the name must always start with an "@".
```
[set] @VAR_NAME VALUE
```

To set a **global** variable the value of which is retained between dialogues, use `set` with a "#" like this:
```
[set] #VAR_NAME VALUE
```

Possible values are floats, integers, strings, booleans or even actions, e.g.:
```
[set] @my_number 12
[set] @my_bool true
[set] @item new_item_by_name("WATER")
```

### if / then / else
`if`, `then` and `else` work as expected. The inline parameter of `if` is tested to be true and than the execution is continued with either `then` or `else` depending on the outcome.

```
[if] time_is_morning()
    [then]
        [text]
        Gerhard: Good Morning
        Avatar: Morning
    [else]
        [text]
        Gerhard: G`Day
        Avatar: Same
```

```
[if] item_name_eq(@item, "WATER")
    [then]
        [text]
        Gerhard: Here some water.
        Avatar: Thx
```

### action
`action` interacts with the game over the same api as [Condition](#condition). It always returns a value.

```
[action] change_stage("HOME")
```

```
[action] give_player_item(@item)
```

