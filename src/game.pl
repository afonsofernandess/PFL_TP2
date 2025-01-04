:- use_module(library(random)).
:- use_module(library(lists)).

% Entry point of the game
play :-
    format('Welcome to Doblin!~n', []),
    format('Select game mode:~n', []),
    format('1. Human vs Human~n', []),
    format('2. Human vs PC~n', []),
    format('3. PC vs Human~n', []),
    format('4. PC vs PC~n', []),
    read(GameMode),
    configure_game(GameMode, GameConfig),
    initial_state(GameConfig, GameState),
    game_loop(GameState).

% Configure the game based on the selected mode
configure_game(1, game_config(human, human)).
configure_game(2, GameConfig) :-
    format('Select the level of PC player2:~n', []),
    format('1. Level 1~n', []),
    format('2. Level 2~n', []),
    read(Level),
    GameConfig = game_config(human, pc(Level)).
configure_game(3, GameConfig) :-
    format('Select the level of PC player1:~n', []),
    format('1. Level 1~n', []),
    format('2. Level 2~n', []),
    read(Level),
    GameConfig = game_config(pc(Level), human).
configure_game(4, GameConfig) :-
    format('Select the level of PC player1:~n', []),
    format('1. Level 1~n', []),
    format('2. Level 2~n', []),
    read(Level1),
    format('Select the level of PC player2:~n', []),
    format('1. Level 1~n', []),
    format('2. Level 2~n', []),
    read(Level2),
    GameConfig = game_config(pc(Level1), pc(Level2)).

game_loop(GameState):-
    game_over(GameState, Winner),
    display_winner(Winner).

game_loop(GameState) :-
    display_game(GameState),
    GameState = game_state(CurrentPlayer, Player1Board, Player2Board, Players),
    current_player_type(CurrentPlayer, Players, PlayerType),
    format('Current Player Type: ~w~n', [PlayerType]),

    % Handle player moves
    (PlayerType == pc(1) ->
        handle_pc_move(GameState, 1, NewGameState);
    PlayerType == pc(2) ->
        handle_pc_move(GameState, 2, NewGameState);
    PlayerType == human ->
        handle_human_move(GameState, NewGameState)),

    % Proceed to the next iteration of the loop
    game_loop(NewGameState).

% Handles moves for PC players
handle_pc_move(GameState, Level, NewGameState) :-
    format('PC Level ~w is making moves...~n', [Level]),
    choose_move_x(GameState, Level, MoveX),
    format('PC chooses "x" move: ~w~n', [MoveX]),
    process_move(GameState, MoveX, TempGameState),
    choose_move_o(TempGameState, Level, MoveO),
    format('PC chooses "o" move: ~w~n', [MoveO]),
    process_move(TempGameState, MoveO, TempGameStateAfterO),
    TempGameStateAfterO = game_state(CurrentPlayer, Player1Board, Player2Board, Players),
    next_player(CurrentPlayer, Players, NextPlayer),
    NewGameState = game_state(NextPlayer, Player1Board, Player2Board, Players).


% Handles moves for human players
handle_human_move(GameState, NewGameState) :-
    format('Human is making two moves...~n', []),
    get_valid_move([MoveX, MoveO]), % Changed from `get_valid_move` to reflect plural intent
    format('Human chooses moves: "x" -> ~w, "o" -> ~w~n', [MoveX, MoveO]),

    process_move(GameState, MoveX, TempGameState),
    process_move(TempGameState, MoveO, NGameState),
    NGameState = game_state(CurrentPlayer, Player1Board, Player2Board, Players),
    next_player(CurrentPlayer, Players, NextPlayer),
    NewGameState = game_state(NextPlayer, Player1Board, Player2Board, Players).

% Processes a single move
process_move(GameState, Move, NewGameState) :-
    Move = [Symbol, Col, Row],
    GameState = game_state(CurrentPlayer, Player1Board, Player2Board, Players),
    (is_cell_empty(Player1Board, Row, Col) ->
        move(GameState, Move, NewGameState)
    ;
        format('Invalid move or cell occupied. Try again.~n', []),
        NewGameState = GameState % Maintain state if move is invalid
    ).






% Determine the type of the current player (human or pc)
current_player_type(player1, [Player1, _], PlayerType) :-
    Player1 = PlayerType.
current_player_type(player2, [_, Player2], PlayerType) :-
    Player2 = PlayerType.







% Initializes the game state
initial_state(game_config(Player1, Player2), 
    game_state(player1, Player1Board, Player2Board, [Player1, Player2])) :-
    randomize_headers(Player1Columns),
    randomize_rows(Player1Rows),
    randomize_headers(Player2Columns),
    randomize_rows(Player2Rows),
    initial_board(EmptyBoard),
    create_board(Player1Columns, Player1Rows, EmptyBoard, Player1Board),
    create_board(Player2Columns, Player2Rows, EmptyBoard, Player2Board).

% Initializes an empty board
initial_board([
    ['-', '-', '-', '-', '-', '-', '-', '-'],
    ['-', '-', '-', '-', '-', '-', '-', '-'],
    ['-', '-', '-', '-', '-', '-', '-', '-'],
    ['-', '-', '-', '-', '-', '-', '-', '-'],
    ['-', '-', '-', '-', '-', '-', '-', '-'],
    ['-', '-', '-', '-', '-', '-', '-', '-'],
    ['-', '-', '-', '-', '-', '-', '-', '-'],
    ['-', '-', '-', '-', '-', '-', '-', '-']
]).

% Randomizes column headers
randomize_headers(RandomizedHeaders) :-
    random_permutation(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'], RandomizedHeaders).

% Randomizes row indices
randomize_rows(RandomizedRows) :-
    random_permutation([1, 2, 3, 4, 5, 6, 7, 8], RandomizedRows).

% Creates a randomized board
create_board(RandomizedColumns, RandomizedRows, EmptyBoard, board(RandomizedColumns, RandomizedRows, EmptyBoard)).

% Displays the current players board
display_game(game_state(player1, Player1Board, _, _)) :-
    format('Player 1\'s Turn~n', []),
    display_board(Player1Board).

display_game(game_state(player2, _, Player2Board, _)) :-
    format('Player 2\'s Turn~n', []),
    display_board(Player2Board).

% Displays a single board
display_board(board(Headers, Rows, Board)) :-
    format('  ', []), write_list(Headers), nl,
    display_rows(Board, Rows).

write_list([]).
write_list([H|T]) :- format('~w ', [H]), write_list(T).

display_rows([], []).
display_rows([Row|Board], [RowIndex|RowIndices]) :-
    format('~w ', [RowIndex]),
    write_list(Row), nl,
    display_rows(Board, RowIndices).

% Makes a move
move(game_state(CurrentPlayer, Player1Board, Player2Board, Players), 
    [Symbol, Col, Row], 
    game_state(CurrentPlayer, NewPlayer1Board, NewPlayer2Board, Players)) :-
    place_symbol(Player1Board, Col, Row, Symbol, NewPlayer1Board),
    place_symbol(Player2Board, Col, Row, Symbol, NewPlayer2Board).

place_symbol(board(RandomizedColumns, RandomizedRows, Board), Col, Row, Symbol, board(RandomizedColumns, RandomizedRows, NewBoard)) :-
    nth1(RowIndex, RandomizedRows, Row), % Get the actual row index
    ColCode is Col + 96,                % Convert column to its character code (1 -> 97, 'a')
    char_code(ColChar, ColCode),         % Convert the column code to the character (e.g., 1 -> 'a')
    nth1(ColIndex, RandomizedColumns, ColChar), % Get the actual column index
    nth1(RowIndex, Board, CurrentRow),  % Get the specific row from the board
    replace_in_list(CurrentRow, ColIndex, Symbol, NewRow), % Update the row
    replace_in_list(Board, RowIndex, NewRow, NewBoard). % Update the board



replace_in_list([_|T], 1, X, [X|T]).
replace_in_list([H|T], I, X, [H|R]) :-
    I > 1, I1 is I - 1,
    replace_in_list(T, I1, X, R).

% Determines the next player
next_player(player1, [_, Player2], player2).
next_player(player2, [Player1, _], player1).

% Checks if the game is over
game_over(game_state(_, board(_, _, Board1), board(_, _, Board2), _), Winner) :-
    \+ (member_contains(Board1, '-')),
    \+ (member_contains(Board2, '-')),
    score(Score1, Board1),
    score(Score2, Board2),
    determine_winner(Score1, Score2, Winner).

% Determines the winner based on the scores
determine_winner(Score1, Score2, player1) :-
    Score1 < Score2.
determine_winner(Score1, Score2, player2) :-
    Score2 < Score1.
determine_winner(Score1, Score2, draw) :-
    Score1 =:= Score2.

display_winner(player1) :-
    format('Player 1 wins!~n', []).
display_winner(player2) :-
    format('Player 2 wins!~n', []).
display_winner(draw) :-
    format('It\'s a draw!~n', []).

member_contains(Board, Symbol) :-
    member(Row, Board),
    member(Symbol, Row).

% Reads a valid move
% Reads two valid moves for the round
get_valid_move([MoveX, MoveO]) :-
    format('Enter your "x" move (e.g., b3): ', []),
    read(InputX),
    process_input_x(InputX, MoveX),
    format('Enter your "o" move (e.g., a1): ', []),
    read(InputO),
    process_input_o(InputO, MoveO),


    !.  % Exit loop if both inputs are valid

% Auxiliar predicate to handle invalid input
get_valid_move(Moves) :-
    format('Invalid move format or coordinates already have a symbol. Try again.~n', []),
    get_valid_move(Moves).  % Retry the input loop

% Processes a single move input
process_input_x(Input, [Symbol, Col, Row]) :-
    atom_chars(Input, [ColChar, RowChar]),
    valid_move_format(['x', ColChar, RowChar]), % Assume "x" and "o" moves are fixed
    Symbol = 'x',
    char_code(RowChar, RowCode),
    Row is RowCode - 48, % Convert char '1' to integer 1
    char_code(ColChar, ColCode),
    Col is ColCode - 96. % Convert char 'a' to integer 1

process_input_o(Input, [Symbol, Col, Row]) :-

    atom_chars(Input, [ColChar, RowChar]),
    valid_move_format(['o', ColChar, RowChar]),
    Symbol = 'o',
    char_code(RowChar, RowCode),
    Row is RowCode - 48,
    char_code(ColChar, ColCode),
    Col is ColCode - 96.


% Validates the format of a move
valid_move_format([Symbol, ColChar, RowChar]) :-
    member(Symbol, ['x', 'o']),
    char_code(ColChar, ColCode),
    ColCode >= 97, ColCode =< 104,  
    char_code(RowChar, RowCode),
    RowCode >= 49, RowCode =< 56.   


parse_move(Input, Symbol, Col, Row) :-
    atom(Input), % Ensure Input is an atom
    atom_chars(Input, [ColChar, RowChar]),
    member(Symbol, ['x', 'o']), % Symbol must be valid
    char_code(ColChar, ColCode),
    ColCode >= 97, ColCode =< 104, % Ensure column is 'a' to 'h'
    Col is ColCode - 96, % Convert 'a'-'h' to 1-8
    char_code(RowChar, RowCode),
    RowCode >= 49, RowCode =< 56, % Ensure row is '1' to '8'
    Row is RowCode - 48. % Convert '1'-'8' to 1-8




is_cell_empty(board(RandomizedColumns, RandomizedRows, Board), Row, Col) :-
    nth1(RowIndex, RandomizedRows, Row), % Get the actual row index

    ColCode is Col + 96,
    char_code(ColChar, ColCode),
    nth1(ColIndex, RandomizedColumns, ColChar), % Get the actual column index
    nth1(RowIndex, Board, BoardRow), % Get the specific row from the board
    nth1(ColIndex, BoardRow, '-'). % Check if the cell is empty

% Auxiliar predicate to check if Sub is a sublist of List
sublist(Sub, List) :-
    append(_, Rest, List),
    append(Sub, _, Rest).

% Calculates the total score of a board
score(Total, Board) :-
    count_lines(Board, x, HX),
    count_vertical_lines(Board, x, VX),
    count_diagonal_lines(Board, x, DX),
    count_squares(Board, x, SX),
    XScore is HX + VX + DX + SX,
    count_lines(Board, o, HO),
    count_vertical_lines(Board, o, VO),
    count_diagonal_lines(Board, o, DO),
    count_squares(Board, o, SO),
    OScore is HO + VO + DO + SO,
    Total is XScore + OScore.

% Count horizontal lines of 4 for a given symbol
count_lines(Board, Symbol, Count) :-
    count_lines_aux(Board, Symbol, 0, Count).

count_lines_aux([], _, Acc, Acc).
count_lines_aux([Row|Rest], Symbol, Acc, Count) :-
    count_in_row(Row, Symbol, LineCount),
    NewAcc is Acc + LineCount,
    count_lines_aux(Rest, Symbol, NewAcc, Count).

count_in_row(Row, Symbol, Count) :-
    findall(_, sublist([Symbol, Symbol, Symbol, Symbol], Row), Matches),
    length(Matches, Count).

% Count vertical lines of 4 for a given symbol
count_vertical_lines(Board, Symbol, Count) :-
    transpose(Board, Transposed),
    count_lines(Transposed, Symbol, Count).

% Transpose the board in order to simplify counting vertical lines
transpose([], []).
transpose([[]|_], []).
transpose(Matrix, [Row|Rest]) :-
    maplist(head, Matrix, Row),
    maplist(tail, Matrix, TailMatrix),
    transpose(TailMatrix, Rest).

head([H|_], H).
tail([_|T], T).

% Count diagonal lines of 4 for a given symbol
count_diagonal_lines(Board, Symbol, Count) :-
    findall(_, diagonal_match(Board, Symbol), Diagonals),
    length(Diagonals, Count).

diagonal_match(Board, Symbol) :-
    nth1(Row, Board, RowList),
    nth1(Col, RowList, Symbol),
    check_diagonal(Board, Row, Col, Symbol).

check_diagonal(Board, Row, Col, Symbol) :-
    extract_diagonal(Board, Row, Col, 1, [Symbol, Symbol, Symbol, Symbol]).
check_diagonal(Board, Row, Col, Symbol) :-
    extract_diagonal(Board, Row, Col, -1, [Symbol, Symbol, Symbol, Symbol]).

extract_diagonal(Board, Row, Col, Dir, [Symbol|Rest]) :-
    within_bounds(Board, Row, Col),
    nth1(Row, Board, RowList),
    nth1(Col, RowList, Symbol),
    NextRow is Row + 1,
    NextCol is Col + Dir,
    extract_diagonal(Board, NextRow, NextCol, Dir, Rest).
extract_diagonal(_, _, _, _, []).

within_bounds(Board, Row, Col) :-
    length(Board, NumRows),
    Row > 0, Row =< NumRows,
    nth1(Row, Board, RowList),
    length(RowList, NumCols),
    Col > 0, Col =< NumCols.

% Count 2x2 squares
count_squares(Board, Symbol, Count) :-
    findall(_, square_match(Board, Symbol), Matches),
    length(Matches, Count).

square_match(Board, Symbol) :-
    nth1(Row, Board, RowList1),
    NextRow is Row + 1,
    nth1(NextRow, Board, RowList2),
    nth1(Col, RowList1, Symbol),
    NextCol is Col + 1,
    nth1(Col, RowList2, Symbol),
    nth1(NextCol, RowList1, Symbol),
    nth1(NextCol, RowList2, Symbol).






choose_move_x(GameState, 1, Move) :-
    valid_moves(GameState, ValidMoves),
    % Filter valid moves to include only those starting with "x"
    include(valid_x_move, ValidMoves, XMoves),
    (   XMoves = [] 
    ->  Move = none  % Indicate no move is possible
    ;   random_member(Move, XMoves)
    ).

% Predicate to check if the move starts with "o"
valid_x_move([X, _, _]).

choose_move_o(GameState, 1, Move) :-
    valid_moves(GameState, ValidMoves),
    % Filter valid moves to include only those starting with "o"
    include(valid_o_move, ValidMoves, OMoves),
    (   OMoves = [] 
    ->  Move = none  % Indicate no move is possible
    ;   random_member(Move, OMoves)
    ).

% Predicate to check if the move starts with "o"
valid_o_move([o, _, _]).


choose_move(GameState, 2, Move) :-
    valid_moves(GameState, ValidMoves),
    % implement the logic for the PC level 2
    random_member(Move, ValidMoves).


% Make sure the column is converted to a numeric value (1-8)
valid_move(PlayerBoard, Symbol, Col, Row) :-
    between(1, 8, Col), % Ensure Col is within the valid range
    between(1, 8, Row), % Ensure Row is within the valid range
    is_cell_empty(PlayerBoard, Row, Col),
    member(Symbol, ['x', 'o']). % Ensure Symbol is valid


% Get the list of all valid moves for a given game state
valid_moves(GameState, ListOfMoves) :-
    GameState = game_state(_, Player1Board, _, _),
    findall([Symbol, Col, Row], (
        member(Symbol, ['x', 'o']),
        valid_move(Player1Board, Symbol, Col, Row)
    ), ListOfMoves).



between(Low, High, Value) :-
    Low =< High,
    between_helper(Low, High, Value).

% Helper predicate for generating values.
between_helper(Current, High, Current) :-
    Current =< High.
between_helper(Current, High, Value) :-
    Current < High,
    Next is Current + 1,
    between_helper(Next, High, Value).