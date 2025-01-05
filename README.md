# PFL_TP2
# Doblin

### Identification:
- João Miguel Peixoto Lamas (up202208948) - 50% (implemented algorithm for PC level 2 and the scoring system as well as very needed code revisions)
- Pedro Afonso Nunes Fernandes (up202207987) - 50% (implemented the game logic, including player interactions, and game mechanics, as well as creating the README documentation )




## Installation and Execution: 
For installing the first step is to unzip the PFL_TP2_T03_Doblin_3.zip. Then for the execution of the program you need to follow the next steps:

- step 1 - rlwrap /usr/local/sicstus4.9.0/bin/./sicstus
- step 2 - consult('/home/path/to/PFL_TP2_T03_Doblin_3/src/game.pl').
- step 3 - play.

## Description of the game:
Doblin is board game designed for 1 to multiple players. The game challenges players to strategically fill grids without forming specific patterns of repeated symbols, such as squares or lines, making it an engaging mix of logic and spatial reasoning.

The objective is to be the player with the `fewest lines or squares of four identical symbols` by the end of the game.
Each player is assigned an `8x8` grid with a unique random arrangement of letters and numbers on the axes.

Players take turns selecting two empty spaces on their grid and marking one with `O` and the other with `X` and all players must replicate the same markings in the corresponding positions on their grids.
The game ends when all grids are filled.

Each forbidden pattern (lines or squares) scores `1 point`.
The player with the lowest total score wins.

https://boardgamegeek.com/boardgame/308153/doblin
https://www.reddit.com/r/boardgames/comments/g7wkqb/doblin_a_solo_and_multiplayer_pen_paper_game_rules/


## Considerations for game extensions: 
describe the considerations taken into account when extending
the game design, namely when considering variable-sized boards, optional rules (e.g., simplified rules
for novice players, additional rules for expert players), and other aspects.
## Game Logic: 

### Game Configuration Representation:
The configuration for the game is specified in the predicate `configure_game/2`, which maps the user's selection to a `game_config/2` structure. This structure includes the types of players (human or PC) and, in the case of PC, their difficulty levels.

Representation:
- `game_config(Player1, Player2)`

 Player1 and Player2 are either human or pc(Level), where Level specifies the PC difficulty (e.g., 1 for easy, 2 for hard).   

The `initial_state/2` predicate uses the game configuration to set up the initial game state, which includes the turn order and the boards for both players.

### Internal Game State Representation:

The game state is represented by the `game_state/4` structure:

**Structure:** `game_state(CurrentPlayer, Player1Board, Player2Board, Players)`

- **CurrentPlayer**: Indicates the active player (`player1` or `player2`).
- **Player1Board, Player2Board**: Boards representing the states of each player's pieces.
- **Players**: List of player types (`[Player1Type, Player2Type]`).

#### Initial State:

```game_state(player1, board([...], [...], [['-', '-', ...], ...]), board([...], [...], [['-', '-', ...], ...]), [human, pc(1)])```

#### Intermidiate state
```game_state(player2, board([...], [...], [['-', 'o', ...], ...]), board([...], [...], [['x', '-', ...], ...]), [human, pc(1)])```

#### Final State
```game_state(player1, board([...], [...], [['x', 'x', ...], ...]), board([...], [...], [['o', 'o', ...], ...]), [human, pc(1)])```


**Board Representation**
Boards are stored as a structure:

**Structure:** `board(Columns, Rows, Grid)`

- **Columns**: List of randomized column labels (`['a', 'b', ..., 'h']`).
- **Rows**: List of randomized row indices (`[1, 2, ..., 8]`).
- **Grid**: 8x8 matrix initialized with `'-'` (empty cells).

---

**Atom Meanings**
- `'-'`: Empty cell.
- `'x'`: Symbol for one player's moves.
- `'o'`: Symbol for the other player's moves.

### Move Representation:

Moves in the game are represented as a combination of a symbol `('x' or 'o')`, a column `(a to h)`, and a row `(1 to 8)`. Internally, these moves are encoded in the format `[Symbol, Col, Row]`, where:

- **Symbol:** Indicates the player’s piece being placed `('x' or 'o')`
- **Col:** A numeric representation of the column `(1 for 'a', 2 for 'b', and so on)`
- **Row:** A numeric representation of the row `(1 to 8)`.

The move/3 predicate processes these moves by validating the move's format and ensuring the target cell is empty, updating the game state by placing the symbol on the specified coordinates of the player's board. This structure allows seamless parsing and validation of moves during gameplay while maintaining clarity and flexibility in handling user and PC input.


### User Interaction:


The game features an intuitive menu system that guides the user through setup and gameplay:

**Main Menu:** Prompts the user to choose between game modes:

```
Human vs Human
Human vs Computer
Computer vs Human
Computer vs Computer
```

**PC Level Selection:** For games involving AI, the user is prompted to select the difficulty level for each computer player (`Level 1` or `Level 2`).

**Input Validation:** During gameplay, the system:

- Prompts human players to input moves in the format `a1`, where `a` is the column and `1` is the row.
- Validates the input format (ensuring it falls within the board's bounds).
- Checks that the target cell is empty before proceeding.
- Provides clear feedback for invalid input and re-prompts the user until a valid move is entered.

This interactive design ensures a smooth user experience, minimizing errors and providing clarity at every step.


## Conclusions: 


While the program is currently free of known issues, there is considerable potential for future improvements. We can enhance the game by implementing features such as:
- A graphical user interface (transition from a text-based interface to a graphical one for a more visually appealing experience with animations for piece placement).
- An option to choose board size 6x6-10x10.
- An implementation of the single mode that the game has.
- Provide post-game analytics, including move history, strategies used, and performance metrics.

## Bibliography: 

Game information:

- https://boardgamegeek.com/boardgame/308153/doblin
- https://www.reddit.com/r/boardgames/comments/g7wkqb/doblin_a_solo_and_multiplayer_pen_paper_game_rules/

Game implementation:

- Moodle Course Powerpoints 

## Annex
### Inicial State

![Inicial State](../PFL_TP2/images/inicial_state.png "Inicial State")

### Itermidiate State
![Itermidiate State](../PFL_TP2/images/intermidiate_state.png)

### Final State
![Final State](../PFL_TP2/images/final_state.png)




### Invalid Move
![INvalid Move](../PFL_TP2/images/invalid_move.png)

### Menu

![Menu](../PFL_TP2/images/menu.png)

### PC Level

![Pc Level](../PFL_TP2/images/pc_level.png)

### PC Turn

![Pc Turn](../PFL_TP2/images/pc_turn.png)

### Score

![Score](../PFL_TP2/images/scores.png)

