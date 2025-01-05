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
configure_game(2, game_config(human, pc(Level))) :-
    select_pc_level('1', Level).
configure_game(3, game_config(pc(Level), human)) :-
    select_pc_level('2', Level).
configure_game(4, game_config(pc(Level1), pc(Level2))) :-
    select_pc_level('1', Level1),
    select_pc_level('2', Level2).

% Select the level of the PC player
select_pc_level(Player, Level) :-
    format('~nSelect the level of PC player ~w:~n', [Player]),
    format('1. Level 1~n', []),
    format('2. Level 2~n', []),
    read(Level).

% Determine the type of the current player (human or pc)
current_player_type(player1, [Player1, _], Player1).
current_player_type(player2, [_, Player2], Player2).

% Gets the current player and the list of players
player_info(game_state(CurrentPlayer, _, _, Players), CurrentPlayer, Players).

% Determines the next player
next_player(player1, _, player2).
next_player(player2, _, player1).

set_next_player(game_state(CurrentPlayer, Player1Board, Player2Board, Players), 
    game_state(NextPlayer, Player1Board, Player2Board, Players)) :-
    next_player(CurrentPlayer, Players, NextPlayer).

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
    format('Player 1\'s Turn~n~n', []),
    display_board(Player1Board).

display_game(game_state(player2, _, Player2Board, _)) :-
    format('Player 2\'s Turn~n~n', []),
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

% Displays 2 boards beside each other (used for game over)
display_boards_side(board(Headers1, Rows1, Board1), board(Headers2, Rows2, Board2)):-
    format('~n      Player 1              Player 2~n',[]), nl,
    format('  ', []), write_list(Headers1),
    format('      ', []), write_list(Headers2), nl,
    display_rows_side(Board1, Rows1, Board2, Rows2).

display_rows_side([], [], [], []):- nl.
display_rows_side([Row1|Board1], [RowIndex1|RowIndices1], [Row2|Board2], [RowIndex2|RowIndices2]) :-
    format('~w ', [RowIndex1]),
    write_list(Row1),
    format('    ~w ', [RowIndex2]),
    write_list(Row2), nl,
    display_rows_side(Board1, RowIndices1, Board2, RowIndices2).

% Separates the game state
parse_gamestate(game_state(CurrentPlayer, Player1Board, Player2Board, Players), 
    CurrentPlayer, Player1Board, Player2Board, Players).

% Displays the played move in a more readable formmat
display_move([Symbol, Col, Row]) :-
    ColCode is Col + 96,
    char_code(ColChar, ColCode),
    format('Played ~w on ~w.~n', [Symbol, [ColChar,Row]]).

% Handles the turn of a player
turn(human, GameState, NewGameState) :-
    format('Human\'s turn~n', []),
    choose_move(GameState, 0, move('x', Col, Row)),
    move(GameState, ['x', Col, Row], FirstMoveState),
    choose_move(FirstMoveState, 0, move('o', Col2, Row2)),
    move(FirstMoveState, ['o', Col2, Row2], SecondMoveState),
    display_move(['x', Col, Row]),
    display_move(['o', Col2, Row2]),
    set_next_player(SecondMoveState, NewGameState).

turn(pc(1), GameState, NewGameState) :-
    format('PC Level 1 is making moves...~n', []),
    choose_move(GameState, 1, move('x', Col, Row)),
    display_move(['x', Col, Row]),
    move(GameState, ['x', Col, Row], FirstMoveState),
    choose_move(FirstMoveState, 1, move('o', Col2, Row2)),
    display_move(['o', Col2, Row2]),
    move(FirstMoveState, ['o', Col2, Row2], SecondMoveState),
    set_next_player(SecondMoveState, NewGameState).

turn(pc(2), GameState, NewGameState) :-
    format('PC Level 2 is thinking...~n', []),
    choose_move(GameState, 2, move('x', Col, Row)),
    display_move(['x', Col, Row]),
    move(GameState, ['x', Col, Row], FirstMoveState),
    choose_move(FirstMoveState, 2, move('o', Col2, Row2)),
    display_move(['o', Col2, Row2]),
    move(FirstMoveState, ['o', Col2, Row2], SecondMoveState),
    set_next_player(SecondMoveState, NewGameState).

game_loop(GameState):-
    game_over(GameState, Winner),
    display_winner(Winner).

game_loop(GameState) :-
    display_game(GameState),
    player_info(GameState, CurrentPlayer, Players),
    current_player_type(CurrentPlayer, Players, PlayerType),

    turn(PlayerType, GameState, NewGameState),

    % Proceed to the next iteration of the loop
    game_loop(NewGameState).

% Makes a move
move(game_state(CurrentPlayer, Player1Board, Player2Board, Players), 
    [Symbol, Col, Row], 
    game_state(CurrentPlayer, NewPlayer1Board, NewPlayer2Board, Players)) :-
    place_symbol(Player1Board, Col, Row, Symbol, NewPlayer1Board),
    place_symbol(Player2Board, Col, Row, Symbol, NewPlayer2Board).

place_symbol(board(RandomizedColumns, RandomizedRows, Board), Col, Row, Symbol, board(RandomizedColumns, RandomizedRows, NewBoard)) :-
    nth1(RowIndex, RandomizedRows, Row), % Get the actual row index
    ColCode is Col + 96,                % Convert column to its character code (e.g. 1 becomes 97)
    char_code(ColChar, ColCode),         % Convert the column code to the character (e.g. 97 corresponds to 'a')
    nth1(ColIndex, RandomizedColumns, ColChar), % Get the actual column index
    nth1(RowIndex, Board, CurrentRow),  % Get the specific row from the board
    replace_in_list(CurrentRow, ColIndex, Symbol, NewRow), % Update the row
    replace_in_list(Board, RowIndex, NewRow, NewBoard). % Update the board

replace_in_list([_|T], 1, X, [X|T]).
replace_in_list([H|T], I, X, [H|R]) :-
    I > 1, I1 is I - 1,
    replace_in_list(T, I1, X, R).

choose_move(game_state(_, Board, _, _), 0, move('x', Col, Row)) :-
    format('Enter your x move (e.g., a1): ', []),
    read(Input),
    process_input_x(Input, ['x', Col, Row]),
    valid_move(Board, 'x', Col, Row),
    !.  % Exit loop if input is valid

choose_move(GameState, 0, move('x', Col, Row)):-
    format('Invalid move format or cell already occupied. Try again.~n', []),
    choose_move(GameState, 0, move('x', Col, Row)).

choose_move(game_state(_, Board, _, _), 0, move('o', Col, Row)) :-
    format('Enter your o move (e.g., a1): ', []),
    read(Input),
    process_input_o(Input, ['o', Col, Row]),
    valid_move(Board, 'o', Col, Row),
    !.  % Exit loop if input is valid

choose_move(GameState, 0, move('o', Col, Row)):-
    format('Invalid move format or cell already occupied. Try again.~n', []),
    choose_move(GameState, 0, move('o', Col, Row)).

choose_move(GameState, 1, move('x', Col, Row)):-
    valid_moves(GameState, ValidMoves),
    include(valid_x_move, ValidMoves, XMoves),
    random_member([_, Col, Row], XMoves).

choose_move(GameState, 1, move('o', Col, Row)) :-
    valid_moves(GameState, ValidMoves),
    include(valid_o_move, ValidMoves, OMoves),
    random_member([_, Col, Row], OMoves).

choose_move(GameState, 2, move('x', Col, Row)) :-
    valid_moves(GameState, ValidMoves),
    include(valid_x_move, ValidMoves, XMoves),
    find_best_move(GameState, XMoves, [_, Col, Row]).

choose_move(GameState, 2, move('o', Col, Row)) :-
    valid_moves(GameState, ValidMoves),
    include(valid_o_move, ValidMoves, OMoves),
    find_best_move(GameState, OMoves, [_, Col, Row]).

value(game_state(player1, board(_, _, Board), _, _), _, Player1Score) :-
    score(Player1Score, Board, _, _).

value(game_state(player2, _, board(_, _, Board), _), _, Player2Score) :-
    score(Player2Score, Board, _, _).

find_best_move(GameState, ValidMoves, BestMove) :-
    parse_gamestate(GameState, CurrentPlayer, _, _, _),
    findall(Diff-Move, (
        member(Move, ValidMoves),
        simulate_move(GameState, Move, SimulatedState),
        valid_moves(SimulatedState, OpponentMoves),
        calculate_max_opponent_value(SimulatedState, OpponentMoves, MaxOpponentValue),
        value(SimulatedState, CurrentPlayer, CurrentValue),
        compute_diff(CurrentValue, MaxOpponentValue, OpponentMoves, Diff)
    ), ValuedMoves),
    sort(ValuedMoves, SortedValuedMoves),
    keysort(SortedValuedMoves, [_-BestMove|_]).

calculate_max_opponent_value(_, [], 0). % Fallback value if OpponentMoves is empty
calculate_max_opponent_value(SimulatedState, OpponentMoves, MaxOpponentValue) :-
    findall(OpponentValue, (
        member(OpponentMove, OpponentMoves),
        simulate_move(SimulatedState, OpponentMove, OpponentGameState),
        value(OpponentGameState, _, OpponentValue)
    ), OpponentValues),
    max_list(OpponentValues, MaxOpponentValue).

max_list([X], X).

max_list([H|T], Max) :-
    max_list(T, TailMax),
    Max is max(H, TailMax).

compute_diff(CurrentValue, _, [], CurrentValue). % Fallback when no opponent moves
compute_diff(CurrentValue, MaxOpponentValue, [_|_], Diff) :- 
    Diff is MaxOpponentValue - CurrentValue. % Normal case

% Simulate a move on the game state
simulate_move(game_state(player1, Board, _, Players), [Symbol, Col, Row], game_state(_, NewBoard, NewBoard, Players)) :-
    place_symbol(Board, Col, Row, Symbol, NewBoard).

simulate_move(game_state(player2, _, Board, Players), [Symbol, Col, Row], game_state(_, NewBoard, NewBoard, Players)) :-
    place_symbol(Board, Col, Row, Symbol, NewBoard).

valid_x_move([x, _, _]).
valid_o_move([o, _, _]).

% Make sure the column is converted to a numeric value (1-8)
valid_move(PlayerBoard, Symbol, Col, Row) :-
    between(1, 8, Col), % Ensure Col is within the valid range
    between(1, 8, Row), % Ensure Row is within the valid range
    is_cell_empty(PlayerBoard, Row, Col),
    member(Symbol, ['x', 'o']). % Ensure Symbol is valid


% Get the list of all valid moves for a given game state
valid_moves(GameState, ListOfMoves) :-
    parse_gamestate(GameState, _, Player1Board, _, _),
    findall([Symbol, Col, Row], (
        member(Symbol, ['x', 'o']),
        valid_move(Player1Board, Symbol, Col, Row)
    ), ListOfMoves).


% Reads a valid move
% Reads two valid moves for the round
get_valid_move([MoveX, MoveO]) :-
    format('Enter your "x" move (e.g., b3): ', []),
    read(InputX),
    process_input_x(InputX, MoveX),
    format('Enter your "o" move (e.g., a1): ', []),
    read(InputO),
    process_input_o(InputO, MoveO).

% Auxiliar predicate to handle invalid input
get_valid_move(Moves) :-
    format('Invalid move format or coordinates already have a symbol. Try again.~n', []),
    get_valid_move(Moves).  % Retry the input loop

% Processes a single move input
process_input_x(Input, ['x', Col, Row]) :-
    atom_chars(Input, [ColChar, RowChar]),
    valid_move_format(['x', ColChar, RowChar]),
    char_code(RowChar, RowCode),
    Row is RowCode - 48, % Convert char '1' to integer 1
    char_code(ColChar, ColCode),
    Col is ColCode - 96. % Convert char 'a' to integer 1

process_input_o(Input, ['o', Col, Row]) :- 
    atom_chars(Input, [ColChar, RowChar]),
    valid_move_format(['o', ColChar, RowChar]),
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

% Checks if the game is over
game_over(game_state(_, board(Col1, Row1, Board1), board(Col2, Row2, Board2), _), Winner) :-
    \+ (member_contains(Board1, '-')),
    \+ (member_contains(Board2, '-')),
    score(Score1, Board1, (XScore1, HorizontalX1, VerticalX1, DiagonalX1, SquareX1), (OScore1, HorizontalO1, VerticalO1, DiagonalO1, SquareO1)),
    score(Score2, Board2, (XScore2, HorizontalX2, VerticalX2, DiagonalX2, SquareX2), (OScore2, HorizontalO2, VerticalO2, DiagonalO2, SquareO2)),
    display_boards_side(board(Col1, Row1, Board1), board(Col2, Row2, Board2)),
    display_scores_side(Score1, (XScore1, HorizontalX1, VerticalX1, DiagonalX1, SquareX1), (OScore1, HorizontalO1, VerticalO1, DiagonalO1, SquareO1), Score2, (XScore2, HorizontalX2, VerticalX2, DiagonalX2, SquareX2), (OScore2, HorizontalO2, VerticalO2, DiagonalO2, SquareO2)),
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

display_scores_side(Score1, (XScore1, HorizontalX1, VerticalX1, DiagonalX1, SquareX1), (OScore1, HorizontalO1, VerticalO1, DiagonalO1, SquareO1), Score2, (XScore2, HorizontalX2, VerticalX2, DiagonalX2, SquareX2), (OScore2, HorizontalO2, VerticalO2, DiagonalO2, SquareO2)) :-
    format(' --------------------------------------~n', []),
    format('  Hor X lines: ~w        Hor X lines: ~w~n', [HorizontalX1, HorizontalX2]),
    format('  Ver X lines: ~w        Ver X lines: ~w~n', [VerticalX1, VerticalX2]),
    format('  Dia X lines: ~w        Dia X lines: ~w~n', [DiagonalX1, DiagonalX2]),
    format('  X Squares: ~w          X Squares: ~w~n', [SquareX1, SquareX2]),
    format('  X score: ~w            X score: ~w~n', [XScore1, XScore2]),
    format(' --------------------------------------~n', []),
    format('  Hor O lines: ~w        Hor O lines: ~w~n', [HorizontalO1, HorizontalO2]),
    format('  Ver O lines: ~w        Ver O lines: ~w~n', [VerticalO1, VerticalO2]),
    format('  Dia O lines: ~w        Dia O lines: ~w~n', [DiagonalO1, DiagonalO2]),
    format('  O Squares: ~w          O Squares: ~w~n', [SquareO1, SquareO2]),
    format('  O score: ~w            O score: ~w~n', [OScore1, OScore2]),
    format(' --------------------------------------~n', []),
    format('  Total: ~w             Total: ~w~n', [Score1, Score2]),
    format(' --------------------------------------~n', []).

member_contains(Board, Symbol) :-
    member(Row, Board),
    member(Symbol, Row).

% Auxiliar predicate to check if Sub is a sublist of List
sublist(Sub, List) :-
    append(_, Rest, List),
    append(Sub, _, Rest).

% Calculates the total score of a board
score(Total, Board, (XScore, HX, VX, DX, SX), (OScore, HO, VO, DO, SO)) :-
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