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
configure_game(2, game_config(human, pc)).
configure_game(3, game_config(pc, human)).
configure_game(4, game_config(pc, pc)).

% Main game loop
game_loop(GameState) :-
    display_game(GameState),
    (game_over(GameState, Winner) ->
        format('Game over!~nWinner: ~w~n', [Winner])
    ;
        GameState = game_state(CurrentPlayer, Player1Board, Player2Board, Players),
        (CurrentPlayer == pc ->
            choose_move(GameState, Move)
        ;
            get_valid_move(Move)
        ),
        (parse_move(Move, Col, Row) ->
            (is_cell_empty(Player1Board, Row, Col) ->
                move(GameState, [Col, Row], NewGameState),
                game_loop(NewGameState)
            ;   format('Invalid move or cell occupied. Try again.~n', []),
                game_loop(GameState))
        ;   
            format('Invalid move format. Try again.~n', []),
            game_loop(GameState))
    ).

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
    Columns = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'],
    random_permutation(Columns, RandomizedHeaders).

% Randomizes row indices
randomize_rows(RandomizedRows) :-
    Rows = [1, 2, 3, 4, 5, 6, 7, 8],
    random_permutation(Rows, RandomizedRows).

% Creates a randomized board
create_board(RandomizedColumns, RandomizedRows, EmptyBoard, board(RandomizedColumns, RandomizedRows, EmptyBoard)).

% Displays the current players board
display_game(game_state(CurrentPlayer, Player1Board, Player2Board, _)) :-
    (CurrentPlayer == player1 ->
        format('Player 1\'s Turn~n', []),
        display_board(Player1Board)
    ;
        format('Player 2\'s Turn~n', []),
        display_board(Player2Board)
    ).

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
    [Col, Row], 
    game_state(NextPlayer, NewPlayer1Board, NewPlayer2Board, Players)) :-
    type_move(CurrentPlayer, Symbol),
    place_symbol(Player1Board, Col, Row, Symbol, NewPlayer1Board),
    place_symbol(Player2Board, Col, Row, Symbol, NewPlayer2Board),
    next_player(CurrentPlayer, Players, NextPlayer).

place_symbol(board(RandomizedColumns, RandomizedRows, Board), Col, Row, Symbol, board(RandomizedColumns, RandomizedRows, NewBoard)) :-
    nth1(RowIndex, RandomizedRows, Row), % Get the actual row index
    ColCode is Col + 96,
    char_code(ColChar, ColCode),
    nth1(ColIndex, RandomizedColumns, ColChar), % Get the actual column index
    nth1(RowIndex, Board, CurrentRow), % Get the specific row from the board
    replace_in_list(CurrentRow, ColIndex, Symbol, NewRow),
    replace_in_list(Board, RowIndex, NewRow, NewBoard).

replace_in_list([_|T], 1, X, [X|T]).
replace_in_list([H|T], I, X, [H|R]) :-
    I > 1, I1 is I - 1,
    replace_in_list(T, I1, X, R).

% Determines the next player
next_player(player1, [_, Player2], player2).
next_player(player2, [Player1, _], player1).

% Checks if the game is over
game_over(game_state(_, board(_, _, Board1), board(_, _, Board2), _), Winner) :-
    (\+ member_contains(Board1, '-') ->
        Winner = player1
    ;
        \+ member_contains(Board2, '-') ->
        Winner = player2
    ).

member_contains(Board, Symbol) :-
    member(Row, Board),
    member(Symbol, Row).

% Reads a valid move
get_valid_move(Move) :-
    repeat,
    format('Enter your move (e.g., a1): ', []),
    read(Input),
    (process_input(Input, Move) ->
        ! % Valid move, exit loop
    ;   format('Invalid move format. Try again.~n', []), fail).

process_input(Input, [ColChar, RowChar]) :-
    atom_chars(Input, [ColChar, RowChar]),
    valid_move_format([ColChar, RowChar]).

valid_move_format([ColChar, RowChar]) :-
    char_code(ColChar, ColCode),
    ColCode >= 97, ColCode =< 104,
    char_code(RowChar, RowCode),
    RowCode >= 49, RowCode =< 56.

parse_move([ColChar, RowChar], Col, Row) :-
    char_code(RowChar, RowCode),
    Row is RowCode - 48,
    char_code(ColChar, ColCode),
    ColCode >= 97, ColCode =< 104,
    Col is ColCode - 96.

% Checks if a specific cell is empty
is_cell_empty(board(RandomizedColumns, RandomizedRows, Board), Row, Col) :-
    nth1(RowIndex, RandomizedRows, Row), % Get the actual row index
    ColCode is Col + 96, % Convert column number to ASCII code
    char_code(ColChar, ColCode), % Convert ASCII code to character
    nth1(ColIndex, RandomizedColumns, ColChar), % Get the actual column index
    nth1(RowIndex, Board, BoardRow), % Get the specific row from the board
    nth1(ColIndex, BoardRow, Cell), % Get the specific column from the row
    Cell = '-'.

% Stores the move type for each player
type_move(player1, 'x').
type_move(player2, 'o').