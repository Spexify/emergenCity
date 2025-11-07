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
Dialogues with ``[[Type]] stage`` for example are dialogues which are conditioned on a stage and should thus be treated preferentially in the selection of dialogues.

### Type
`type` describes the type of the dialogue. Currently, the only functional type is the **stage** type.

- ``[[Type]] stage``: Dialogues of this type will be treated preferentially in the selection of dialogues.
- ``[[Type]] auto``: Dialogues of this type will be triggered automatically when entering a stage.

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
`Condition` describes the conditions under which the node can be jumped to by [jump](#jump). Here condition interacts directly with the game. Therefore its inline or multiline parameters are interpreted as functions calling the api to the game.
These functions calls can be nested.

```
[Condition] 
and(npc_is_happy("Gerhard"), time_is_morning())
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
avatar.flipped
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
`goto` is a unconditional jump to the node specified by name in its inline argument. There also is a conditional variant called [jump](#jump).-

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
[set] @item [action] new_item_by_name("WATER")
```

### if / then / else / end
`if`, `then` and `else` work as expected. The inline parameter of `if` is tested to be true and than the execution is continued with either `then` or `else` depending on the outcome. The cases are ultimately ended by `end`.

```
[if] [action] time_is_morning()
[then]
[text]
Gerhard: Good Morning
Avatar: Morning
[else]
[text]
Gerhard: G`Day
Avatar: Same
[end]
```

```
[if] [action] item_name_eq(@item, "WATER")
[then]
[text]
Gerhard: Here some water.
Avatar: Thx
[end]
```

### action
`action` interacts with the game over the same api as [Condition](#condition). It always returns a value.

```
[action]
change_stage("HOME")
```

```
[action] give_player_item(@item)
```

#### Possible Actions

The following is an overview of available actions.

##### Progress Day

This action can be used to progress the day if an action takes time (e.g. eating a meal with NPCs). A description is given what is taking time.
```
[action]
- ActCons.progress_day ["Suche nach Friedel"]
```
##### Gain Item

This action can be used to gain an item (in this case, fish) with a description.
```
[action]
- ActCons.add_item_question [["FISH", {"question":"Dieser %s ist sehr frisch.","answere":"","decline":"Einpacken"}]]
```

##### Ghange Scores (TODO)

- Gain points (Genuss): `[action] add_points_mood(OPTIONAL_AMOUNT)` This action can be used to add points to the own mood(?) score.
- Gain points (Gesellschaft): `[action] add_points_social(OPTIONAL_AMOUNT)` This action can be used to add points to the social score.
- Gain points (Information/Wissen): `[action] add_points_knowledge(OPTIONAL_AMOUNT)` This action can be used to add points to the knowledge score.
- Gain calories: `[action] add_points_calories(OPTIONAL_AMOUNT)` This action can be used to gain calories (e.g. due to eating a meal with NPCs).
- Gain water: `[action] add_points_water(OPTIONAL_AMOUNT)` This action can be used to gain water.

If no amount is given, a default amount will be used.

##### Stage Manipulation (TODO)

- Add NPC: `[action] arrive("NPC_NAME")` This action can be used to spawn the NPC ‘NPC_NAME’ in the stage (walks in).
- Remove NPC: `[action] leave("NPC_NAME")` This action can be used to remove the NPC ‘NPC_NAME’ from the stage (walks out).

## Checking Conditions

The following describes in more detail which conditions can be checked with Conditional or if statements and how these checks are called.

### Variables

Variables set with `[set]` can be checked like this for their value:

```
@LOCAL_VAR_NAME VALUE
#GLOBAL_VAR_NAME VALUE
```

e.g.

```
#visited_node true
```

### Karma, Friendship and Mood

Karma is a float between `-1` and `1`. It's influenced by trade. Friendship is an integer that is `0` initially and increased when talking to an NPC and slowly decreases over time when not talking to an NPC. Mood is an NPC state that can be either of: `SAD`, `HAPPY`, `MID`.

All of these can be queried using the following:

```
npc_PROPERTY_higher_than NPC_NAME VALUE
npc_PROPERTY_less_than NPC_NAME VALUE
npc_PROPERTY_equal NPC_NAME VALUE
```

For example, like this:

```
npc_karma_higher_than gerhard 0.5
npc_friendship_higher_than gerhard 8
npc_mood_higher_than agathe MID
```

### Crisis

The current main crisis can be queried like this:

```
[action] crisis_is(CRISIS_NAME)
```

`CRISIS_NAME` can be any of: Chemie, LKW, Duerre, Sturmtief, Hochwasser, Starkregen, Waldbrand, Pandemie.

### Crises Effects

The current crises effects can be queried like this:

```
is_state_by_name_str ElectricityState.NONE
```

Possible states are: `MobileNetState.ONLINE`, `MobileNetState.OFFLINE`, `ElectricityState.NONE`, `ElectricityState.UNLIMITED`, `WaterState.NONE`, `WaterState.DIRTY`, `WaterState.CLEAN`, `FoodContaminationState.NONE`, `FoodContaminationState.FOOD_SPOILED`, `IsolationState.NONE`, `IsolationState.LIMITED_PUBLIC_ACCESS`, `IsolationState.ISOLATION`.

### Stage

The current stage can be queried like this:

```
is_current_stage market
```

Possible stages are: `home`, `market`, `townhall`, `park`, and all npc homes.

### Time

The current time can be queried like this:
```
[action] time_is_morning()
```

Possible times are: `morning`, `midday`, `evening`.

## File Structure

The dialogue file structure looks like the following:

```
NPC_1/
    snippets.vrv (contains different ways of starting/ending or otherwise manipulating a conversation via import)
    small_talk.vrv (contains small talk specific to this NPC)
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
    	first_secret_part_2.vrv
    	second_secret.vrv
    day/ (contains the day dialogues, one is randomly selected each day, currently all day dialogues are in file **day.vrv** instead)
    	day1.vrv
    	day2.vrv
    	...
    market (contains dialogues for the stage market, if the NPC can be met there, currently all day dialogues are in file **market.vrv** instead)
    	market1.vrv
    	market2.vrv
        ...
    park (contains dialogues for the stage park, if the NPC can be met there)
    	park1.vrv
    	park2.vrv
        ...
    townhall (contains dialogues for the stage townhall, if the NPC can be met there)
    	townhall1.vrv
    	townhall2.vrv
        ...
    home (contains dialogues for when the avatar is home and an NPC visits, currently all day dialogues are in file **home.vrv** instead)
        home1.vrv
        home2.vrv
        ...
NPC_2/
...
small_talk/ (contains all small talk shared across NPCs)
    one.vrv
```

Note:
- `market`, `park` and `townhall` are stage dialogues (see `type` above). The probability that one of them is selected is higher than the probability that a day dialogue will be used instead.
- `home` is a special stage dialogue that is triggered when an NPC visits and always overwrites the day dialogue.
- `secret` and `quests` are special dialogues that overwrite the day dialogue.
- `small_talk` are short dialogues used additionally to any of the larger dialogues (i.e. stage, secret, quests).
