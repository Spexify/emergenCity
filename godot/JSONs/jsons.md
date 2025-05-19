# JSON

The following Json files contain text which will be displayed and should therefore be checked for spelling:

- action.json
- books.json
- item.json
- optional_events.json
- scenarios.json
- upgrades.json
- dialogues/
- npcs/

## Action
Actions have the following format:

```json
{
    "type": "single",
    "comp": COMP,
    "method": METHOD,
    "params": [ TEXT ]
}
```

```json
{
    "type": "multi",
    "acc": "or" | "and" | "array",
    "actions": [
        ACTION,
        ACTION
    ]
}
```

```json
{
    "type": "condition",
    "cond": ACTION,
    "if": ACTION,
    "else": ACTION
}
```

Display Text will only ever appear in the value of the params key.
For example when requesting a GUI:

```json
{
    "type": "single",
    "comp": "gui_mngr",
    "method": "request_gui",
    "params": [ 
        "TooltipGUI",
        [
            "Hier steht Text der eventuell auf Rechtschreibung überprüft werden muss."
        ]
     ]
}
```

## Books

Books have the following format:

```json
{
    "ID": ID,
    "title": TEXT,
    "content": [
        TEXT,
        TEXT,
        ...
    ]
}
```

## Item

Items have the following format:

```json
{
    "ID": ID,
    "name": TEXT,
    "descr": TEXT,
    "comps": [ ... ]
}
```

## Optional Event

In optional events there are a lot of keys. You only have to care about ``"descr"``.

## Scenario

Scenarios have the following format:

```json
TITLE: {
    "icon_id": ID,
    "description": TEXT
}
```

You should not change the Title.

## Upgrade

Upgrades have the following format:

```json
{
    {
        "description": TEXT,
		"display_name": TEXT,
		"id": ID,
		"price": PRICE,
		"state": STATE,
		"state_maximum": INT,
		"tilemap_position": POS,
		"atlas_coord": POS,
		"tiles_cols": COLS,
		"tiles_rows": ROW,
    }
}
```

You only have to care about the first two: ``"description"`` and ``"display_name"``.

## Dialogue

Dialogues are sorted in the folder of their respective place at which they may be called,
They have the following format:

```json
{
    KEY: {
        "priority": "",
        "prompt": ...,
        "weight": ...,
		"cooldown": ...,
		"cooldown_end": ...,
        "conditions": { ... } | [ ... ],
        "actors": [ ... , ... ],
        "text": [
            "actor1#TEXT",
            "actor2#TEXT"
        ],
        "options": { ... }
    }
}
```

In dialogues the text always comes after the name of an actor and a `"#"`.
For example: `"gerhard#Dies text muss eventuell korrigiert werden."`

## NPC

NPCs are sorted in the folder of their respective place at which they may be called,
They have the following format:

```json
 {
    "comp": {
        COMP: {},
        COMP: {},
        ...
    }
 }
```

NPCs are build compositional meaning not every NPC has every component.
Some components contain display text while others do not.

Following comps may contain text:

```json
"descr": {
    "name": TEXT,
    "descr": TEXT,
    "portait": IMG
}
```

```json
"interaction": {
   COMP: {},
   "trading": {
        "preferences": { ... },
        "inventory": { ... },
        "bottom": ...,
        "low": ...,
        "mid": ...,
        "high": ...,
        "top": ...,
        "response": {
            KEY: [ TEXT, TEXT, ... ],
        }
   }
}
```

```json
"brain": {
    "actions": {
        KEY: SINGLE_ACTION,
        KEY: MULTI_ACTION,
        KEY: CONDITION_ACTION
    },
    "decide": { ... },
    "comps": {
        COMP: {...},
        COMP: {...},
        ...
    }
}
```

`SINGLE_ACTION`, `MULTI_ACTION` and `CONDITION_ACTION` have the same format as the actions in the beginning.
They may contain display text.
