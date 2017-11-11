% Game Logic

% Attempt to move. 
attempt_to_move(Move) :- 
		is_vertical_or_horizontal(Move), !, 
		once(check_piece_warfare(Move)).


% Check if is horizontal or vertical move. 
is_vertical_or_horizontal(Move) :- 
		vertical(Move) ; 
		horizontal(Move).

horizontal(Move) :- 
		nth0(1, Move, Row), 
		nth0(3, Move, Row), 
		traverse_move_horizontal(Move). 

vertical(Move) :- 
		nth0(0, Move, Column), 
		nth0(2, Move, Column), 
		traverse_move_vertical(Move).  

% Vertical
traverse_move_vertical(Move) :- 
		nth0(0, Move,ColumnLetter), 
		column_to_number(ColumnLetter, Column), 
		nth0(1, Move, Row1), 
		nth0(3, Move, Row2), 
		Row1 \= Row2,
		((Row1 < Row2, NewRow1 is Row1 + 1) ;
		 	(Row1 > Row2, NewRow1 is Row1 -1)),
		check_from_X_to_Y_Row(Column, NewRow1, Row2).

% End Condition 
check_from_X_to_Y_Row(Column, Row, Row) :- 
		get_piece(Column, Row, Piece), 
		equal(Piece,' ').

check_from_X_to_Y_Row(Column, Row1, Row2) :- 
		get_piece(Column, Row1, Piece), 
		equal(Piece,' '),
		((Row1 < Row2, NewRow1 is Row1 + 1) ; 
		 	(Row1 > Row2, NewRow1 is Row1 - 1)), 
		check_from_X_to_Y_Row(Column, NewRow1, Row2).


% Horizontal
traverse_move_horizontal(Move) :- 
		nth0(0, Move,ColumnLetter1), 
		nth0(2, Move, ColumnLetter2), 
		nth0(3, Move, Row),
		column_to_number(ColumnLetter1, Column1), 
		column_to_number(ColumnLetter2, Column2), 
		Column1 \= Column2, 
		((Column1 < Column2, NewColumn1 is Column1 + 1) ; 
		  	(Column1 > Column2, NewColumn1 is Column1 -1)),
		check_from_X_to_Y_Column(Row, NewColumn1, Column2).

% End Condition
check_from_X_to_Y_Column(Row, Column, Column):- 
		get_piece(Column, Row, Piece), 
		equal(Piece,' ').

check_from_X_to_Y_Column(Row, Column1, Column2) :- 
		((Column1 < Column2, NewColumn1 is Column1 + 1) ; 
		 	(Column1 > Column2, NewColumn1 is Column1 -1)),
		get_piece(NewColumn1, Row, Piece), 
		equal(Piece, ' '),
		check_from_X_to_Y_Column(Row, NewColumn1, Column2).

% Checks if player is moving is own piece, not an enemy's or a blank space. 
is_own_piece(Move, Player) :- 
		nth0(0, Move, ColumnLetter), 
		column_to_number(ColumnLetter, Column), 
		nth0(1, Move, Line),
        get_piece(Column, Line, Piece), 
        player_letter(Player, Piece).

% Checks whether piece is in warfare with enemy or not.
check_piece_warfare(Move) :- 
		nth0(0, Move, ColumnLetter), 
		nth0(1, Move, Row), 
		column_to_number(ColumnLetter, Column), !,
		get_piece(Column, Row, Piece), 
		player_letter(Player, Piece),  
        opposing_player(Player,Enemy),
        once(check_surroundings(Player, Enemy, Column, Row)).                   % Analyzes surrounding area to the piece in question.
        
% Starts veryfing surrounding areas.
check_surroundings(Player, Enemy, Column, Row) :-  
		(((NewColumn1 is Column + 1,
			get_piece(NewColumn1, Row, Piece),							  % Analyze all 4 sides of piece
		  	player_letter(N, Piece),
		  	equal(N, Enemy), 
		  	once(is_in_previous_warfare(NewColumn1, Row, Player, Column, Row)), !) ;  % If it finds an enemy, verifies if 
		(NewColumn2 is Column - 1 , 
		  	get_piece(NewColumn2, Row, Piece),                            % it's already in a warfare with an ally.
		  	player_letter(N, Piece), 
		  	equal(N, Enemy), 
		  	once(is_in_previous_warfare(NewColumn2, Row, Player, Column, Row)), !)) ; 
		((NewRow1 is Row + 1, 
		  	get_piece(Column, NewRow1, Piece),
		  	player_letter(N, Piece), 
		  	equal(N, Enemy), 
		  	once(is_in_previous_warfare(Column, NewRow1, Player, Column, Row)), !) ;  
		 (NewRow2 is Row - 1 , 
	 	  	get_piece(Column, NewRow2, Piece),
		   	player_letter(N, Piece), 
		   	equal(N, Enemy), 
		   	once(is_in_previous_warfare(Column, NewRow2, Player, Column, Row)), !))). % If not, then the piece can move.

% If no enemy is around player, he can move without restriction.
check_surroundings(_, _, _, _).

% Checks if surrouding enemy piece is already in warfare with another ally.
is_in_previous_warfare(Column, Row, Player, PlayerColumn, PlayerRow) :-
		is_offensive_move(Player, PlayerColumn, PlayerRow, Column, Row),
		((NewColumn1 is Column + 1, 
			NewColumn1 \== PlayerColumn, 
			get_piece(NewColumn1, Row, Piece),
			player_letter(N, Piece), 
			equal(N, Player)) ;  % If enemy is already surrounded
		 (NewColumn2 is Column - 1 , 
		 	NewColumn2 \== PlayerColumn, 
		 	get_piece(NewColumn2, Row, Piece),
		 	player_letter(N, Piece), 
		 	equal(N, Player)) ; % by an ally, then the piece selected
		 (NewRow1 is Row + 1, NewRow1 \== PlayerRow, 
		 	get_piece(Column, NewRow1, Piece),
		 	player_letter(N, Piece), 
		 	equal(N, Player)) ;        % can move freely.
		 (NewRow2 is Row - 1 , NewRow2 \== PlayerRow, 
		 	get_piece(Column, NewRow2, Piece),
		 	player_letter(N, Piece), 
		 	equal(N, Player))).


is_offensive_move(Player, PlayerColumn, PlayerRow, Column, Row):- 
		opposing_player(Player,Enemy), player_dux(Enemy, EnemyDux),	
		((((NewColumn1 is Column + 1,
			get_piece(NewColumn1, Row, Piece),							  % Analyze all 4 sides of piece
		  	equal(Piece, EnemyDux)) ;  % If it finds an enemy, verifies if 
		(NewColumn2 is Column - 1 , 
		  	get_piece(NewColumn2, Row, Piece),                            % it's already in a warfare with an ally.
		  	equal(Piece, EnemyDux))) ; 
		((NewRow1 is Row + 1, 
		  	get_piece(Column, NewRow1, Piece),
		  	equal(Piece, EnemyDux)) ;  
		 (NewRow2 is Row - 1 , 
	 	  	get_piece(Column, NewRow2, Piece),
		   	equal(Piece, EnemyDux))))).

% Sees what piece is in position. IMPORTANT NOTE: Column is a number, not a letter. Conversion must be made previously. 
get_piece(Column,Line,Piece):- 
        board(Board), 
        (Column > 0, Column < 11, line_to_position(Line, LineNumber),
        nth1(LineNumber, Board, X), 
        nth1(Column, X, Piece), !).

% If it's not a valid position.
get_piece(_,_,_,Piece):- 
        Piece = 'x'.

% Replaces a character in a given position on the board.
set_piece(ColumnLetter,Line,Piece):- 
        column_to_number(ColumnLetter, Column), 
        line_to_position(Line, LineNumber),                                   
        board(Board), 
        replace(Board,LineNumber,Column,Piece,NewBoard),
        retract(board(Board)),
        assert(board(NewBoard)).


replace( [L|Ls] , 1 , ColumnNumber , Piece , [R|Ls] ) :-        % once we find the desired row,
        replace_column(L,ColumnNumber,Piece,R).                       % - we replace specified column, and we're done.

replace( [L|Ls] , LineNumber , ColumnNumber , Piece , [L|Rs] ) :-      % if we haven't found the desired row yet
        LineNumber > 1 ,                                                     % - and the row offset is positive,
        X1 is LineNumber-1 ,                                                 % - we decrement the row offset
        replace( Ls , X1 , ColumnNumber , Piece , Rs ).                      % - and recurse down                                     

replace_column( [_|Cs] , 1 , Piece , [Piece|Cs] ).             % once we find the specified offset, just make the substitution and finish up.

replace_column( [C|Cs] , ColumnNumber , Piece , [C|Rs] ) :-     % otherwise,
        ColumnNumber > 1 ,                                            % - assuming that the column offset is positive,
        Y1 is ColumnNumber-1 ,                                        % - we decrement it
        replace_column( Cs , Y1 , Piece , Rs ).                       % - and recurse down.