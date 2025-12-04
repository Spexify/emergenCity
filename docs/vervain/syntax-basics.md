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

The special node named **start** is the starting point of each dialogue:
```
[[Node]] start
```

## Node level
Directive in this category start with a capital letter. They describe the attributes of a [node](#node) and may only appear once per [node](#node).

### Condition
`Condition` describes the conditions under which the node can be jumped to by [jump](#jump). Here condition interacts directly with the game. Therefore its inline parameters are interpreted as functions calling the api to the game.
These functions calls can be nested.

```
[Condition] and_bool(npc_is_happy("gerhard"), time_is_morning())
```

If only of of the conditions need to be true, you can use `or_bool`.

To negate the conditional value, use not_bool, e.g. to query if a given NPC is not happy (but either mid or sad) you can use:
```
[Condition] not_bool(npc_is_happy("npc_name"))
```

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
`action` interacts with the game over the same api as [Condition](#condition). It always returns a value. Each action needs to be preceded by the `action` directive:

```
[action] action1
[action] action2
```

The following is an overview of available actions.

#### Stage Manipulation

- **Move player**: `change_stage("HOME")` This action can be used to move the player to a different stage.
- **Add NPC**: `arrive("npc_name")` This action can be used to spawn the NPC ‘npc_name’ in the stage (walks in).
- **Remove NPC**: `leave("npc_name")` This action can be used to remove the NPC ‘npc_name’ from the stage (walks out).

Possible stages are: `HOME`, `MARKET`, `TOWNHALL`, `PARK`, and all npc homes.

#### Time Manipulation

This action can be used to progress the day if an action takes time (e.g. eating a meal with NPCs). A description is provided of what is taking time.
```
progress_day("Suche nach Friedel")
```

#### Gain Item

This action can be used to gain an item.
```
gain_player_item("ITEM_NAME", "description")
```

e.g.

```
gain_player_item("JAM", "This is special jam!")
```

#### Gain Scores

- **Gain knowledge**: `add_score("tip", {"source": "julia1"})` This action can be used to add points to the knowledge score. Each source must be unique to add points only once.
- **Gain calories**: `add_points_calories(OPTIONAL_AMOUNT)` This action can be used to gain calories (e.g. due to eating a meal with NPCs).
- **Gain water**: `add_points_water(OPTIONAL_AMOUNT)` This action can be used to gain water.

If no amount is given, a default amount will be used.

#### Initiate trade

```request_trade_gui("npc_name")```

### Conditional actions

The following is a list of actions used to query game states.

#### Variables

Variables set with `[set]` can be checked like this for their value:

```
eq_TYPE(@LOCAL_VAR_NAME, VALUE)
eq_TYPE(#GLOBAL_VAR_NAME, VALUE)
```

where TYPE is the data type (currently either a string, integer or bool) e.g.

```
eq_bool(#visited_node_1,true)
```

#### Karma and Friendship

Karma is a float between `-1` and `1`. It's influenced by trade. Friendship is an integer that is `0` initially and increased when talking to an NPC and slowly decreases over time when not talking to an NPC.

Both of them can be queried using the following:

```
npc_PROPERTY_higher_than("npc_name", VALUE)
npc_PROPERTY_less_than("npc_name", VALUE)
npc_PROPERTY_equal("npc_name", VALUE)
```

For example, like this:

```
npc_karma_higher_than("gerhard",0.5)
npc_friendship_higher_than("gerhard", 8)
```

#### Mood

Mood is an NPC state that can be either sad, happy or mid (i.e. neutral).
```
npc_is_happy("gerhard")
npc_is_sad("gerhard")
```

#### Crisis

The current main crisis can be queried like this:

```
crisis_is("CRISIS_NAME")
```

`CRISIS_NAME` can be any of: Chemie, LKW, Duerre, Sturmtief, Hochwasser, Starkregen, Waldbrand, Pandemie.

#### Crises Effects

The current crises effects can be queried like this:

```
is_state_by_name_str("ElectricityState.NONE")
```

Possible states are: `MobileNetState.ONLINE`, `MobileNetState.OFFLINE`, `ElectricityState.NONE`, `ElectricityState.UNLIMITED`, `WaterState.NONE`, `WaterState.DIRTY`, `WaterState.CLEAN`, `FoodContaminationState.NONE`, `FoodContaminationState.FOOD_SPOILED`, `IsolationState.NONE`, `IsolationState.LIMITED_PUBLIC_ACCESS`, `IsolationState.ISOLATION`.

#### Stage

The current stage can be queried like this:

```is_current_stage("MARKET")```

Possible stages are: `HOME`, `MARKET`, `TOWNHALL`, `PARK`, and all npc homes.

#### Time

The current time can be queried like this:
```
time_is_morning()
```

Possible times are: `morning`, `midday`, `evening`.

#### Roll a dice

```randomize(INT,MAX)```

Returns true when a random number between 1 and the integer `MAX` equals the integer `INT`.

## Comments

To add comments, use the `command` directive and indentation:

```
[Comment]
    All of this will be ignored
    [...] directives will also be ignored
```

## File Structure

The dialogue file structure looks like the following:

```
NPC_1/
    small_talk.vrv (contains small talk specific to this NPC, one is randomly selected each day)
    purpose/ (contains different purposes)
    	purpose1.vrv
    	purpose2.vrv
        ...
    quest/ (contains different quests)
    	quest1.vrv
    	quest2.vrv
        ...
    event/ (contains the dialogues for events the NPC participates in)
    	event1.vrv
    	event2.vrv
        ...
    secrets/ (contains the secrets, each file is called exactly once)
    	first_secret.vrv
    	first_secret_part_2.vrv (optional, used only if the first secret is split into two conversations)
    	second_secret.vrv
    day/ (contains the day dialogues, one is randomly selected each day)
    	day.vrv
    market (contains dialogues for the stage `market`, if the NPC can be met there)
    	market.vrv
    park (contains dialogues for the stage `park`, if the NPC can be met there)
    	park.vrv
    townhall (contains dialogues for the stage townhall, if the NPC can be met there)
    	townhall.vrv
    home (contains dialogues for when the avatar is home and an NPC visits)
        home.vrv
NPC_2/
...
small_talk/ (contains all small talk shared across NPCs)
    one.vrv
```

Note:
- `market`, `park` and `townhall` are special stage dialogues. The probability that one of them is selected is higher than the probability that a day dialogue will be used instead.
- `home` is a special stage dialogue that is triggered when an NPC visits and always overwrites the day dialogue.
- `secrets` and `quest` are special dialogues that overwrite the day dialogue.
- `small_talk` are short dialogues used additionally to any of the larger dialogues (i.e. stage, secret, quests).
