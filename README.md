# Settlers Game Notation

This document defines a notation for the game island colonization game Settlers, called "Settlers Game Notation" (SGN). SGN is represented as JSON and is designed to capture "what happened" for a game of Settlers. However, just like with Chess notation, many actions can be implied without being logged. For instance it is not necessary to record an "end turn" action, as the next player rolling the dice implies that the prior player's turn is finished. This philosophy helps to keep the notation clean, lean and simple.

## Goal

As far as this author is aware, there is no formal, public and free notation for Settlers. This document aims to establish a common language for recording games of Settlers that can be used to implement Settlers software components like games, clients, servers and AI.

## Status

Version 1.0 is a complete notation and considered final. No further changes are expected to the notation. This README is subject to change for errors and typos.

## JSON Schema

The file [message.json](schema/v1.0/message.json) is a complete JSON schema for an SGN message.

## Example

A complete example game log of v1.0 SGN is included in this repo, [game.log](test-corpus/game.log). This includes over 10 rounds of play, using every example message from this schema.

## Tests

The [t](t) directory has test scripts in Perl and JavaScript. [messages.json](test-corpus/messages.json) contains example valid and invalid messages used for testing. The Perl tests can be run from the root project directory with `prove`, which require [JSON::Validator](https://metacpan.org/pod/JSON::Validator) and [JSON::XS](https://metacpan.org/pod/JSON::XS):

    $ prove -l
    prove -l
    t/messages.t .. ok
    All tests successful.
    Files=1, Tests=25,  0 wallclock secs ( 0.02 usr  0.01 sys +  0.19 cusr  0.02 csys =  0.24 CPU)
    Result: PASS

If you prefer node.js, you can run the JavaScript tests, which requires [ajv](https://github.com/epoberezkin/ajv):

    $ t/messages.js
    ok 1 - load schema
    ok 2 - Build City
    ...
    ok 25 - Map Definition: missing harbors
    1..25

## Definition

A valid SGN document a string of newline-separated JSON messages. The idea is to capture the entirety of a game of Settlers from setup to end. The order of messages is always sequential: an SGN document could describe just the game setup for example. But it couldn't describe the deployment phase unless the setup phase is also defined earlier in the same document.

## Messages

Every action in a game of Settlers is described in a message format. A message is a JSON array with the following members:

    Index  Value
    -------------------------------------------------------------------
    0      The number of the player making the action ("1" - "6")
    1      The two letter action code (see Actions below)
    2      The value associated with the action code (see Events below)

## Hexes

All hexes (tiles) are numbered, including sea tiles, using the axial (trapezoidal) coordinate system:

               0,-3  1,-3  2,-3   3,-3
           -1,-2  0,-2  1,-2   2,-2   3,-2
       -2,-1  -1,-1  0,-1   1,-1   2,-1   3,-1
    -3,0   -2,0   -1,0    0,0    1,0    2,0    3,0
       -3,1   -2,1   -1,1   0,1    1,1    2,1
          -3,2   -2,2   -1,2  0,2    1,2
             -3,3   -2,3   -1,3  0,3

This is the same map with the sea tiles represented by tildes (incorrect notation but easier to interpret visually):

             ~~~~  ~~~~  ~~~~   ~~~~
          ~~~~ 0,-2   1,-2   2,-2  ~~~~
       ~~~~  -1,-1  0,-1  1,-1  2,-1  ~~~~
    ~~~~  -2,0   -1,0   0,0   1,0   2,0  ~~~~
       ~~~~  -2,1   -1,1   0,1   1,1  ~~~~
          ~~~~  -2,2   -1,2   0,2  ~~~~
             ~~~~   ~~~~   ~~~~  ~~~~

Hex notation is used to define the layout of the board tiles, and other game objects like the location of the robber.

## Tile Codes

A tile can be any one of the `tCode` values below:

    tCode Type
    --------------
    H     Hills
    D     Desert
    M     Mountains
    S     Sea
    F     Fields
    FO    Forest
    P     Pastures

## Resource Number

A tile can have one resource number on it (the `rNumber`), valid numbers are between 2-6 and 8-12. There is also a limit on the frequency of resource numbers. These are all the available resource numbers for a basic game:

    2,3,3,4,4,5,5,6,6,8,8,9,9,10,10,11,11,12

## Tile Notation

A tile is defined by its hex coordinates, type code and resource number. This is a central desert tile:

    {
      tile: [0,0],
      tCode: "D",
      "rNumber": null
    }

## Intersections

Intersections represent a point between 3 hex locations in a clockwise order. Intersections are represented as an array of 3 hex locations. E.g. the six intersections of the center hex:

                   [[0,-1],[0,0],[-1,0]]
                           /   \
    [[0,-1],[0,0],[-1,0]] /     \  [[1,-1],[1,0],[0,0]]
                         |  0,0  |
                         |       |
    [[0,0],[-1,1],[-1,0]] \     /  [[1,0],[0,1],[0,0]]
                           \   /
                   [[0,1],[-1,1],[0,0]]


Intersections are used to define the location of settlements and cities.

## Paths

Paths are lines between contiguous intersections and are represented as an array of intersections. Each path must have at least two intersections:

    [ [[0,0],[-1,1],[-1,0]], [[0,1],[-1,1],[0,0]] ]

Paths are used to define where harbors and roads are placed.

## Harbors

Harbors are placed on paths adjacent to sea tiles. There are 6 harbor codes (`hCode`):

    hCode  Type
    --------------------
    HR     Generic Harbor
    HRB    Brick Harbor
    HRG    Grain Harbor
    HRL    Lumber Harbor
    HRO    Ore Harbor
    HRW    Wool Harbor

Typical maps will have 4 generic harbors and 1 of every other kind.

## Defining the map

Every tile is listed with its coordinates, type code and resource number. `null` represents no resource number. Harbors are declared at path locations with the harbor type code. A starter map layout:

    {
      "tiles": [
        {"tile":[0,-3],"tCode":"S","rNumber":null},
        {"tile":[1,-3],"tCode":"S","rNumber":null},
        {"tile":[2,-3],"tCode":"S","rNumber":null},
        {"tile":[3,-3],"tCode":"S","rNumber":null},
        {"tile":[3,-2],"tCode":"S","rNumber":null},
        {"tile":[3,-1],"tCode":"S","rNumber":null},
        {"tile":[3,0],"tCode":"S","rNumber":null},
        {"tile":[2,1],"tCode":"S","rNumber":null},
        {"tile":[1,2],"tCode":"S","rNumber":null},
        {"tile":[0,3],"tCode":"S","rNumber":null},
        {"tile":[-1,3],"tCode":"S","rNumber":null},
        {"tile":[-2,3],"tCode":"S","rNumber":null},
        {"tile":[-3,3],"tCode":"S","rNumber":null},
        {"tile":[-3,2],"tCode":"S","rNumber":null},
        {"tile":[-3,1],"tCode":"S","rNumber":null},
        {"tile":[-3,0],"tCode":"S","rNumber":null},
        {"tile":[-2,-1],"tCode":"S","rNumber":null},
        {"tile":[-1,-2],"tCode":"S","rNumber":null},
        {"tile":[1,-2],"tCode":"P","rNumber":12},
        {"tile":[2,-2],"tCode":"F","rNumber":9},
        {"tile":[2,-1],"tCode":"P","rNumber":10},
        {"tile":[2,0],"tCode":"F","rNumber":8},
        {"tile":[1,1],"tCode":"M","rNumber":3},
        {"tile":[0,2],"tCode":"FO","rNumber":6},
        {"tile":[-1,2],"tCode":"F","rNumber":2},
        {"tile":[-2,2],"tCode":"M","rNumber":5},
        {"tile":[-2,1],"tCode":"H","rNumber":8},
        {"tile":[-2,0],"tCode":"D","rNumber":null},
        {"tile":[-1,-1],"tCode":"H","rNumber":4},
        {"tile":[0,-1],"tCode":"M","rNumber":6},
        {"tile":[1,-1],"tCode":"H","rNumber":5},
        {"tile":[1,0],"tCode":"FO","rNumber":4},
        {"tile":[0,1],"tCode":"P","rNumber":9},
        {"tile":[-1,1],"tCode":"P","rNumber":10},
        {"tile":[-1,0],"tCode":"FO","rNumber":3},
        {"tile":[0,0],"tCode":"F","rNumber":11}
      ],
      "harbors": [
        {"path":[[[0,-3],[0,-2],[-1,-2]],  [[1,-3],[0,-2],[0,-3]]],   "hCode": "HR"},
        {"path":[[[2,-3],[1,-2],[1,-3]],   [[2,-3],[2,-2],[1,-2]]],   "hCode": "HRW"},
        {"path":[[[3,-2],[2,-1],[2,-2]],   [[3,-2],[3,-1],[2,-1]]],   "hCode": "HR"},
        {"path":[[[3,-1],[3,0],[2,0]],     [[3,0],[2,1],[2,0]]],      "hCode": "HR"},
        {"path":[[[2,1],[1,2],[1,1]],      [[1,1],[1,2],[0,2]]],      "hCode": "HRB"},
        {"path":[[[0,2],[-1,3],[-1,2]],    [[-1,2],[-1,3],[-2,3]]],   "hCode": "HRL"},
        {"path":[[[-2,2],[-2,3],[-3,3]],   [[-2,2],[-3,3],[-3,2]]],   "hCode": "HR"},
        {"path":[[[-2,1],[-3,2],[-3,1]],   [[-2,0],[-2,1],[-3,1]]],   "hCode": "HRG"},
        {"path":[[[-1,-1],[-2,0],[-2,-1]], [[-1,-2],[-1,-1],[-2,-1]]],"hCode": "HRO"}
      ]
    }

## Resources

There are 5 types of resources, defined by their `rCode`:

    rCode  Type
    ------------
    B      Brick
    G      Grain
    L      Lumber
    O      Ore
    W      Wool

## Resources notation

Resources notation records which resources and in what quantity are being traded by players with the bank or with each other.

It uses the resource code (`rCode`) as the key and the value as the quantity. Both quantities gained and lost are listed. So a trade between player 1 and player 2 for 2 lumber for a wool looks like:

    [
      {"player":"1", resources:{"L":-2,"W": 1},
      {"player":"2", resources:{"L": 2,"W":-1}
    ]

The implication of this notation is that all resources must balance. For trades with the bank, `B` represents the bank. Here is a bank trade by player 2, losing 4 grain to get a brick:

    [
      {"player":"2", resources:{"G":-4,"B": 1},
      {"player":"B", resources:{"G": 4,"B":-1}
    ]

## Assets

Players may accumulate these throughout the game. There are four normal and two special types:

    Name              How to get it
    ---------------------------------------------------
    Development card  Build development card action (BD)
    Settlement        Build settlement action (BS)
    City              Build city action (BC)
    Road              Build road action (BR)
    Largest army      Largest Army - gained by playing at least 3 knight cards, and more than any other player
    Longest road      Longest Road - gained by building at least 5 connected roads, and more than any other player

There are 5 types of development cards:

    cCode  Name
    --------------------
    KN     Knight
    MO     Monopoly
    RB     Road building
    VP     Victory Point
    YP     Year of plenty

## Actions

Actions are taken by players. Every message in SGN is an action, consisting of an action code and a JSON object:

    aCode Name                    Value
    --------------------------------------------------------------------------------------
    BC    Build City              {"player":"#","intersection":<intersection coordinates>}
    BD    Build Development card  {"player":"#",cCode": "KN|MO|RB|VP|YP"}
    BR    Build Road              {"player":"#",path":<path coordinates>}
    BS    Build Settlement        {"player":"#",intersection":<intersection coordinates>}
    DM    Define Map              {"tiles":[...], "harbors":[...]}
    MR    Move Robber             {"tile": <tile coordinates>}
    PD    Play Development card   {"cCode": "KN|MO|RB|VP|YP", "rCodes":[]}
    RD    Roll Dice               {"result":#}
    ST    Steal                   {"resources":<resource notation>}
    TR    Trade                   {"resources":<resource notation>}

Play Development card has an optional value: `rCodes`. This is required when playing Year of Plenty or Monopoly development cards and is an array containing the resources codes for the event. Monopoly can only ever be declared on one resource. Here is an example of playing Monopoly for Ore:

    {"value":{"rCodes":["O"],"cCode":"MO"},"player":"2","aCode":"PD"}

The player using Year of Plenty can declare up to two different resources, e.g. Grain and Brick:

    {"value":{"rCodes":["G","B"],"cCode":"YP"},"player":"2","aCode":"PD"}

Other development cards do not require the `rCodes` property.

## Trading

Trading is a big part of Settlers. Players may trade with each other or with the Bank.

Bank trades are described using the trade action. For example, here's a trade between the Bank ("B") and player 2:

    {
      "aCode": "TR",
      "value":[{"player":"B","resources":{"B":"-1","O":"4"}},{"player":"2","resources":{"B":"1","O":"-4"}}]
      }
    }

Here is an example trade between player 1 and player 2:

    {
      "aCode":"TO",
      "value": {"resources":[{"player":"1","B":-2,"W":1},{"player":"2","B":2,"W":-1}]},
    },

The exchange begins with a Trade offer from player 1 for 1 wool in exchange for 2 brick to player 2. Player 2 accepts the offer, and this triggers the Trade action.

## Players

Players are just string identifiers that refer to a player of the game or the banker. Player "1" is always the player that goes first, up until player "6" (the maximum number of players).

One player name is special and reserved: `B` refers to the banker.

## See Also

[Pioneers](http://pio.sourceforge.net/) an open source implementation of the island colonization game.

[Catan](http://playcatan.com) the official website for Settlers of Catan.

## Version

1.0

## Changes

## 1.0 2016-11-06

The object schema has been changed to array. This is easier to read and avoids key sorting issues with dynamic languages. Compare these v0.4 messages:

    {"value":{"tile":["-2","0"]},"player":"1","aCode":"MR"}
    {"aCode":"BS","player":"1","value":{"intersection":[["0","-2"],["-1","-1"],["-1","-2"]]}}
    {"value":{"path":[[["0","-2"],["-1","-1"],["-1","-2"]],[["0","-2"],["0","-1"],["-1","-1"]]]},"aCode":"BR","player":"1"}
    {"player":"2","aCode":"BS","value":{"intersection":[["0","2"],["-1","3"],["-1","2"]]}}

With the same messages in v1.0 SGN:

    ["1","MR",{"tile":["-2","0"]}]
    ["1","BS",{"intersection":[["0","-2"],["-1","-1"],["-1","-2"]]}]
    ["1","BR",{"path":[[["0","-2"],["-1","-1"],["-1","-2"]],[["0","-2"],["0","-1"],["-1","-1"]]]}]
    ["2","BS",{"intersection":[["0","2"],["-1","3"],["-1","2"]]}]

## 0.4 2016-10-26

The schema has been tested and the version bumped to 0.4, to match `schema/` directory structure. A complete example game log in 0.4 SGN is also provided. This version is ready to be used.

### 0.04 2016-10-06

Events are now called Actions. The idea is to strip out anything that can be inferred and only record what is left. Server type attributes like "UUID" are not required.

### 0.03 2015-12-24

Messages can include a batch value. Added the trade decline event. Changed the definition of tiles and harbors to be objects rather than arrays. Resource notation is now an array of objects that include a player property. Removed `player` from every event value, except for Player Add (it was redundant). Types of things are identified by new names: `tCodes` for tile codes, `hCodes` for harbor codes and `cCodes` for development card codes. Added new `VI` event type. Defined SGN schemas for log and messages.

### 0.02 2015-11-25

Ports are declared on paths instead of tiles. SGN messages have event code, value, sender and UUID attributes.

### 0.01 2015-11-20

Initial release

## Author

David Farrell, &copy; 2016

## License

FreeBSD, see LICENSE
