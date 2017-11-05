% Game Logic

% Attempt to move. 
attempt_to_move(Move) :- is_vertical_or_horizontal(Move), !, check_piece_warfare(Move).

% Check if is horizontal or vertical move. 
is_vertical_or_horizontal(Move) :- vertical(Move) ; horizontal(Move).

horizontal(Move) :- nth0(1, Move, Row), nth0(3, Move, Row), board(Board), traverse_move_horizontal(Board, Move). 
vertical(Move) :- nth0(0, Move, Column), nth0(2, Move, Column), board(Board), traverse_move_vertical(Board, Move).  

% Vertical
traverse_move_vertical(Board, Move) :- nth0(0, Move,ColumnLetter), column_to_number(ColumnLetter, Column), nth0(1, Move, Row1), nth0(3, Move, Row2), Row1 \= Row2,
			((Row1 < Row2, NewRow1 is Row1 + 1) ; (Row1 > Row2, NewRow1 is Row1 -1)), check_from_X_to_Y_Row(Board, Column, NewRow1, Row2).

% End Condition 
check_from_X_to_Y_Row(Board, Column, Row, Row) :- get_piece(Board, Column, Row, Piece), equal(Piece,' ').

check_from_X_to_Y_Row(Board, Column, Row1, Row2) :- get_piece(Board, Column, Row1, Piece), equal(Piece,' '),
		((Row1 < Row2, NewRow1 is Row1 + 1) ; (Row1 > Row2, NewRow1 is Row1 - 1)), check_from_X_to_Y_Row(Board, Column, NewRow1, Row2).

% Horizontal
traverse_move_horizontal(Board, Move) :- nth0(0, Move,ColumnLetter1), nth0(2, Move, ColumnLetter2), nth0(3, Move, Row),
		column_to_number(ColumnLetter1, Column1), column_to_number(ColumnLetter2, Column2), Column1 \= Column2, 
		((Column1 < Column2, NewColumn1 is Column1 + 1) ; (Column1 > Column2, NewColumn1 is Column1 -1)),
		check_from_X_to_Y_Column(Board, Row, NewColumn1, Column2).

% End Condition
check_from_X_to_Y_Column(Board, Row, Column, Column):- get_piece(Board, Column, Row, Piece), equal(Piece,' ').

check_from_X_to_Y_Column(Board, Row, Column1, Column2) :- ((Column1 < Column2, NewColumn1 is Column1 + 1) ; (Column1 > Column2, NewColumn1 is Column1 -1)),
		get_piece(Board, NewColumn1, Row, Piece), equal(Piece, ' '), check_from_X_to_Y_Column(Board, Row, NewColumn1, Column2).

% Checks if player is moving is own piece, not an enemy's or a blank space. 
is_own_piece(Move, Player) :- nth0(0, Move, ColumnLetter), column_to_number(ColumnLetter, Column), nth0(1, Move, Line), board(Board), 
        get_piece(Board, Column, Line, Piece), player_letter(Player, Piece).

% Checks whether piece is in warfare with enemy or not.
check_piece_warfare(Move) :- nth0(0, Move, ColumnLetter), nth0(1, Move, Row), board(Board), column_to_number(ColumnLetter, Column),
		get_piece(Board, Column, Row, Piece), player_letter(Player, Piece),  
        ((equal(Player, 1), Enemy = 2) ; (equal(Player, 2), Enemy = 1)),     % Sees which piece is it's enemy
        check_surroundings(Player, Enemy, Column, Row), !.                   % Analyzes surrounding area to the piece in question.
        
% Starts veryfing surrounding areas.
check_surroundings(Player, Enemy, Column, Row) :- write('Check Surroundings'), board(Board), 
		(((NewColumn1 is Column + 1, get_piece(Board, NewColumn1, Row, Piece),							  % Analyze all 4 sides of piece
		 player_letter(N, Piece), equal(N, Enemy), !, is_in_previous_warfare(NewColumn1, Row, Player, Column, Row)) ;  % If it finds an enemy, verifies if 
		 (NewColumn2 is Column - 1 , get_piece(Board, NewColumn2, Row, Piece),                            % it's already in a warfare with an ally.
		 player_letter(N, Piece), equal(N, Enemy), !, is_in_previous_warfare(NewColumn2, Row, Player, Column, Row))) ; 
		 ((NewRow1 is Row + 1, get_piece(Board, Column, NewRow1, Piece),
		 player_letter(N, Piece), equal(N, Enemy), !, is_in_previous_warfare(Column, NewRow1, Player, Column, Row)) ;  
		 (NewRow2 is Row - 1 , get_piece(Board, Column, NewRow2, Piece),
		 player_letter(N, Piece), equal(N, Enemy), !, is_in_previous_warfare(Column, NewRow2, Player, Column, Row)))). % If not, then the piece can move.

% If no enemy is around player, he can move without restriction.
check_surroundings(_, _, _, _).

% Checks if surrouding enemy piece is already in warfare with another ally.
is_in_previous_warfare(Column, Row, Player, PlayerColumn, PlayerRow) :- board(Board),
		((NewColumn1 is Column + 1, NewColumn1 \== PlayerColumn, get_piece(Board, NewColumn1, Row, Piece),
			player_letter(N, Piece), equal(N, Player)) ;  % If enemy is already surrounded
		 (NewColumn2 is Column - 1 , NewColumn2 \== PlayerColumn, get_piece(Board, NewColumn2, Row, Piece),
		 	player_letter(N, Piece), equal(N, Player)) ; % by an ally, then the piece selected
		 (NewRow1 is Row + 1, NewRow1 \== PlayerRow, get_piece(Board, Column, NewRow1, Piece),
		 	player_letter(N, Piece), equal(N, Player)) ;        % can move freely.
		 (NewRow2 is Row - 1 , NewRow2 \== PlayerRow, get_piece(Board, Column, NewRow2, Piece),
		 	player_letter(N, Piece), equal(N, Player))).