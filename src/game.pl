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
        GameState = game_state(CurrentPlayer, _, _),
        (CurrentPlayer == pc ->
            choose_move(GameState, Move)
        ;
            get_valid_move(Move)
        ),
        (parse_move(Move, Symbol, Col, Row) ->
            move(GameState, Move, NewGameState),
            game_loop(NewGameState)
        ;   
            format('Invalid move. Try again.~n', []),
            game_loop(GameState))
    ).

% Initializes the game state
initial_state(game_config(Player1, Player2), game_state(player1, Board, [Player1, Player2])) :-
    randomize_headers(Columns),
    randomize_rows(Rows),
    initial_board(Board),
    assertz(board_headers(Columns)),
    assertz(board_rows(Rows)).

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
randomize_headers(Columns) :-
    Columns = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'],
    random_permutation(Columns, RandomizedHeaders),
    retractall(board_headers(_)),
    assertz(board_headers(RandomizedHeaders)).

% Randomizes row indices
randomize_rows(Rows) :-
    Rows = [1, 2, 3, 4, 5, 6, 7, 8],
    random_permutation(Rows, RandomizedRows),
    retractall(board_rows(_)),
    assertz(board_rows(RandomizedRows)).

% Displays the board
display_game(game_state(CurrentPlayer, Board, _)) :-
    format('Current Player: ~w~n', [CurrentPlayer]),
    board_headers(Headers),
    board_rows(RowMapping),
    format('  ', []), write_list(Headers), nl,
    display_rows(Board, RowMapping).

write_list([]).
write_list([H|T]) :- format('~w ', [H]), write_list(T).

display_rows(Board, RowMapping) :-
    maplist(display_row(Board), RowMapping).

display_row(Board, LogicalRow) :-
    nth1(LogicalRow, Board, Row),
    format('~w ', [LogicalRow]),
    write_list(Row), nl.

% Makes a move
move(game_state(CurrentPlayer, Board, Players), Move, game_state(NextPlayer, NewBoard, Players)) :-
    parse_move(Move, Symbol, Col, Row),
    place_symbol(Board, Col, Row, Symbol, NewBoard),
    next_player(CurrentPlayer, Players, NextPlayer).

place_symbol(Board, Col, Row, Symbol, NewBoard) :-
    nth1(Row, Board, CurrentRow),
    nth1(Col, CurrentRow, '-', _),  
    replace_in_list(CurrentRow, Col, Symbol, NewRow),
    replace_in_list(Board, Row, NewRow, NewBoard).

replace_in_list([_|T], 1, X, [X|T]).
replace_in_list([H|T], I, X, [H|R]) :-
    I > 1, I1 is I - 1,
    replace_in_list(T, I1, X, R).

% Determines the next player
next_player(player1, [_, Player2], player2).
next_player(player2, [Player1, _], player1).

% Checks if the game is over
game_over(game_state(_, Board, _), Winner) :-
    \+ member_contains(Board, '-').

member_contains(Board, Symbol) :-
    member(Row, Board),
    member(Symbol, Row).


% Reads a valid move
get_valid_move(Move) :-
    repeat,
    format('Enter your move (e.g., xa1): ', []),
    read(Input),
    (process_input(Input, Move) ->
        ! % Valid move, exit loop
    ;   format('Invalid move format. Try again.~n', []), fail).

process_input(Input, Move) :-
    atom_chars(Input, [Symbol, ColChar, RowChar]),
    valid_move_format([Symbol, ColChar, RowChar]),
    Move = [Symbol, ColChar, RowChar].

valid_move_format([Symbol, ColChar, RowChar]) :-
    member(Symbol, ['x', 'o']),
    char_code(ColChar, ColCode),
    ColCode >= 97, ColCode =< 104,
    char_code(RowChar, RowCode),
    RowCode >= 49, RowCode =< 56.

parse_move([Symbol, ColChar, RowChar], Symbol, Col, Row) :-
    % Convert RowChar to a number directly (1 corresponds to index 1, etc.)
    char_code(RowChar, RowCode),
    Row is RowCode - 48,
    board_headers(Headers),
    nth1(Col, Headers, ColChar).


