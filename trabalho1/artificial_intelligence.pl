/************************/
/***** AI BEHAVIOUR *****/
/************************/

/**
*AI moves for a player passed in argument. 
*Gets all moves possible, and chooses a random one
*moves the piece, and removes any captured pieces caused by that move
*checks if the game is over    
*/
aI_move(Player, 1):- 
	cls, nl, nl,
 	
	write('                                           LATRUNCULLI \n \n \n'), 
	format('                                        Player ~w is thinking...\n', [Player]), 
        
	print_board, nl, nl, sleep(2),
	gather_all_moves([[]|ListOfMoves],Player),!,
	nonvar(ListOfMoves),
	length(ListOfMoves,X),
	X>0,
	random_member(NL, ListOfMoves),
        create_move(NL, Move),
        move(Move),
	
        cls, nl, nl,
        write('                                           LATRUNCULLI              \n \n \n'),
        write('                                   Watch it all unfold before you!    \n\n'), 
        format('                                        Player ~w is thinking...\n', [Player]), 
        print_board, nl, nl,  
        format('                                           Player ~w did move :\n', [Player]),
        write( '                                           '), write(Move), write('.'), sleep(2),
	
        remove_captured_pieces(Move,Player),
        is_game_over(Player).

/**
*AI moves for a player passed in argument. 
*Gets all moves possible, and chooses the best move possible given priorities
*moves the piece, and removes any captured pieces caused by that move
*checks if the game is over    
*/
aI_move(Player, 2):- 
	cls, nl, nl,
	
	write('                                           LATRUNCULLI \n \n \n'),
        write('                                 Watch it all unfold before you!\n\n'), 
        format('                                      Player ~w is thinking...\n', [Player]), 
        
	print_board, nl, nl, sleep(2), 

	gather_all_moves([[]|ListOfMoves],Player),!,
	nonvar(ListOfMoves), 
	length(ListOfMoves,X),
	X>0,
        choose_best_move(ListOfMoves, Player, Move),
        move(Move),

        cls, nl, nl,
        write('                                           LATRUNCULLI              \n \n \n'),
        write('                                   Watch it all unfold before you!    \n\n'), 
        format('                                        Player ~w is thinking...\n', [Player]), 
        print_board, nl, nl,  
        format('                                         Player ~w did move :\n', [Player]),
        write( '                                            '), write(Move), write('.\n'),
	write('                                        '),
	remove_captured_pieces(Move,Player),  sleep(2),
        is_game_over(Player).


/**
*Chooses the best move in a list following the priorities
*/
choose_best_move_helper([], _, NL,CurrentBestCapturedPieces, NumberofCaptures, FoundAttackDux):-
        NumberofCaptures>0,
        NL=CurrentBestCapturedPieces;
        FoundAttackDux\= [],
        NL=FoundAttackDux.
                 
choose_best_move_helper([Move|T], Player, NL,CurrentBestCapturedPieces, NumberofCaptures, FoundAttackDux):- 
        create_move(Move, H),
        does_move_check_mate(H,Player),
        NL=H;
        create_move(Move, H),
        move_X_Captured_Pieces(H,Player,Counter), 
        Counter>NumberofCaptures, 
        choose_best_move_helper(T, Player, NL,H, Counter, FoundAttackDux);
        create_move(Move, H),
        NumberofCaptures<1,
	nth0(2,H,ColumnLetter), 
        nth0(3,H,Line), 
	Pos=[ColumnLetter,Line],
        does_move_attack_dux(Pos,Player),
        choose_best_move_helper(T, Player, NL,CurrentBestCapturedPieces, NumberofCaptures, H);
        choose_best_move_helper(T, Player, NL,CurrentBestCapturedPieces, NumberofCaptures, FoundAttackDux).
                
choose_best_move(ListOfMoves, Player, NL):-
	random_permutation(ListOfMoves, NewRandomList),
	choose_best_move_helper(NewRandomList, Player, NL,[], 0, []);  
	random_member(Move, ListOfMoves),
        create_move(Move, NL).

/**
*Gather all moves for all pieces.
*/
gather_all_moves([ListOfMoves|FinalList], Player) :- 
		board(Board), 
		ListOfMoves = [], 
		gather_moves_recursive(Board, ListOfMoves, 8, Player, FinalList).

% Recursive function that calls itself to see all the pieces.
gather_moves_recursive([Row|Tail], ListOfMoves, RowNumber, Player, FinalList) :- 
		RowNumber > 0, 
		gather_moves_by_row(Row, [], 1, RowNumber,  Player, Tmp2List), 
		NewRow is RowNumber - 1, 
		once(append(Tmp2List, ListOfMoves, NewList)), 
		gather_moves_recursive(Tail, NewList, NewRow, Player, FinalList).

% End of recursion.
gather_moves_recursive(_, ListOfMoves, _, _, FinalList) :- 
		copy(ListOfMoves, FinalList).

% Gather all pieces in a Row.
gather_moves_by_row([Piece|Tail], ListOfMoves, ColumnNumber, RowNumber, Player, FinalList) :- 
		RowNumber > 0, 
		NewColumn is ColumnNumber + 1,  
		NewColumn < 12, 
		player_letter(Player, Piece),
		gather_moves_piece(Piece, ColumnNumber, RowNumber, [], TmpList), 
		append(TmpList, ListOfMoves, NewList),
		gather_moves_by_row(Tail, NewList, NewColumn, RowNumber, Player, FinalList). 

% Gather all pieces in a Row.
gather_moves_by_row([_|Tail], ListOfMoves, ColumnNumber, RowNumber, Player, FinalList) :- 
		RowNumber > 0, 
		NewColumn is ColumnNumber + 1, 
		NewColumn < 12, 
		gather_moves_by_row(Tail, ListOfMoves, NewColumn, RowNumber, Player, FinalList).

% Has reached the ending of row.
gather_moves_by_row(_, ListOfMoves, _, _, _, FinalList) :-
			copy(ListOfMoves, FinalList).

% Gather all moves in a specific place.			
gather_moves_piece(_, ColumnNumber, RowNumber, ListOfMoves, FinalList) :- 
		NewRow1 is RowNumber - 1, 
		gather_moves_down(ListOfMoves, ColumnNumber, RowNumber, ColumnNumber, NewRow1, FinalList).

gather_moves_left(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :- 
		get_piece(ColumnNumber, RowNumber, NewPiece), 
		NewPiece == ' ', 
		column_to_number(OriginalColumnLetter, OriginalColumn),
		column_to_number(ColumnNumberLetter, ColumnNumber),
		check_piece_warfare([OriginalColumnLetter, OriginalRow, ColumnNumberLetter, RowNumber]),
		once(append(ListOfMoves, [[OriginalColumn, OriginalRow, ColumnNumber, RowNumber]], NewList)),
		NewColumn1 is ColumnNumber - 1, 
		NewColumn1 > 0,  
		gather_moves_left(NewList, OriginalColumn, OriginalRow, NewColumn1, OriginalRow, FinalList).

% Has reached the end of column, or hit another piece.
gather_moves_left(ListOfMoves, OriginalColumn, OriginalRow, _, _, FinalList) :- 
		NewColumn1 is OriginalColumn + 1, 
		gather_moves_right(ListOfMoves, OriginalRow, OriginalRow, NewColumn1, OriginalRow, FinalList). 

gather_moves_right(_, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :- 
    	get_piece(ColumnNumber, RowNumber, NewPiece), 
    	NewPiece == ' ', 
		NewColumn1 is ColumnNumber + 1, 
		NewColumn1 < 12,
		column_to_number(OriginalColumnLetter, OriginalColumn),
		column_to_number(ColumnNumberLetter, ColumnNumber),
		check_piece_warfare([OriginalColumnLetter, OriginalRow, ColumnNumberLetter, RowNumber]),
		gather_moves_right(_, OriginalColumn, OriginalRow, NewColumn1, OriginalRow, FinalList).

% Has reached the end of column, or hit another piece.
gather_moves_right(ListOfMoves, _, _, _, _, FinalList) :- 
		copy(ListOfMoves, FinalList). 

gather_moves_up(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :-
		get_piece(ColumnNumber, RowNumber, NewPiece), 
		NewPiece == ' ', 
		NewRow1 is RowNumber + 1, 
		NewRow1 < 9, 
		column_to_number(OriginalColumnLetter, OriginalColumn),
		column_to_number(ColumnNumberLetter, ColumnNumber),
		check_piece_warfare([OriginalColumnLetter, OriginalRow, ColumnNumberLetter, RowNumber]),
		once(append(ListOfMoves, [[OriginalColumn, OriginalRow, ColumnNumber, RowNumber]], NewList)), 
		gather_moves_up(NewList, OriginalColumn, OriginalRow, OriginalColumn, NewRow1, FinalList).

% Has reached the end of row, or hit another piece.
gather_moves_up(ListOfMoves, OriginalColumn, OriginalRow, _, _, FinalList) :- 
 		NewColumn1 is OriginalColumn - 1, 
 		gather_moves_left(ListOfMoves, OriginalColumn, OriginalRow, NewColumn1, OriginalRow, FinalList). 

gather_moves_down(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :-
		NewRow1 is RowNumber - 1, 
		NewRow1 > 0,
		get_piece(ColumnNumber, RowNumber, NewPiece), 
		NewPiece == ' ', 
		column_to_number(OriginalColumnLetter, OriginalColumn),
		column_to_number(ColumnNumberLetter, ColumnNumber),
		check_piece_warfare([OriginalColumnLetter, OriginalRow, ColumnNumberLetter, RowNumber]),
		once(append(ListOfMoves, [[OriginalColumn, OriginalRow, ColumnNumber, RowNumber]], NewList)),
		gather_moves_down(NewList, OriginalColumn, OriginalRow, OriginalColumn, NewRow1, FinalList).

% Has reached the end of row, or hit another piece.
gather_moves_down(ListOfMoves, OriginalColumn, OriginalRow, _, _, FinalList) :- 
		NewRow1 is OriginalRow + 1, 
		gather_moves_up(ListOfMoves, OriginalColumn, OriginalRow, OriginalColumn, NewRow1, FinalList). 


/****************************/
 %NUMBER 1 PRIORITY               
/***************************/

/**
* Checks if a move causes the enemy dux to be immobalized
*/
does_move_check_mate_helper(Move,Player,Direction):-
        nth0(2, Move, PosX), 
        nth0(3, Move, PosY), 
        Pos = [PosX,PosY],
        add1_pos(Direction,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),                                    
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_dux(OppPlayer,Piece),
	move(Move),
        (helper_check_mate(Player,NextPiece),de_move(Move);
	de_move(Move),fail).  

does_move_check_mate(Move,Player):-
	does_move_check_mate_helper(Move,Player,1);
	does_move_check_mate_helper(Move,Player,2);
	does_move_check_mate_helper(Move,Player,3);
        does_move_check_mate_helper(Move,Player,4).            



/******************************/
%NUMBER 2 PRIORITY
/*****************************/
 
/**
*Checks if a move captures any piece if it does returns the number of pieces it captures
*/
move_X_Captured_Pieces(Move,Player,Counter):-
	checks_the_direction_of_move(Move,Direction),
        nth0(2, Move, PosX), 
        nth0(3, Move, PosY), 
        Pos = [PosX,PosY],
        is_move_flank_attack(Pos,Direction,Player,CounterFlank),
        is_move_phalanx_attack(Pos,Direction,Player,CounterPhalanx),
        is_move_push_and_crush_capture(Pos,Direction,Player,CounterPushAndCrush),
        is_move_normal_capture1(Pos,Player,Counter1),
        is_move_normal_capture2(Pos,Player,Counter2),
        is_move_normal_capture3(Pos,Player,Counter3),
        is_move_normal_capture4(Pos,Player,Counter4),
        Counter is CounterFlank+CounterPhalanx+CounterPushAndCrush+Counter1+Counter2+Counter3+Counter4, 
        Counter >0.

%checks if the move causes a flank capture
is_move_flank_attack(Pos,Direction,Player,Counter):-
	add1_pos(Direction,Pos,NextPiece), 
	nth0(0,NextPiece,ColumnLetter), 
	nth0(1,NextPiece,Line),                          
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),        
        helper_flank_attack(NextPiece,Direction,Player,0),                                                                                            
        Counter is 1.

is_move_flank_attack(_,_,_,Counter):-Counter is 0.

%checks if the move causes a phalanx capture
is_move_phalanx_attack(Pos,Direction,Player,Counter):-
	add1_pos(Direction,Pos,NextPiece), 
	nth0(0,NextPiece,ColumnLetter), 
	nth0(1,NextPiece,Line),          
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        player_letter(Player,Piece),                              
        directions_90(Direction,X,_), 
        helper_phalanx_attack(Direction,X,Pos,NextPiece,Player,1),
        Counter is 1.                                         

is_move_phalanx_attack(Pos,Direction,Player,Counter):-
	add1_pos(Direction,Pos,NextPiece), 
	nth0(0,NextPiece,ColumnLetter), 
	nth0(1,NextPiece,Line),          
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        player_letter(Player,Piece),                              
        directions_90(Direction,_,X), 
        helper_phalanx_attack(Direction,X,Pos,NextPiece,Player,1),
        Counter is 1.                                       

is_move_phalanx_attack(_,_,_,Counter):- 
		Counter is 0.

%checks if the move causes a push and crush capture
is_move_push_and_crush_capture(Pos,Direction,Player,Counter):-
	add1_pos(Direction,Pos,NextPiece), 
	nth0(0,NextPiece,ColumnLetter), 
	nth0(1,NextPiece,Line),             
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        player_letter(Player,Piece),                                         
        helper_push_and_crush_capture(NextPiece,Direction,Player,1),
        Counter is 1.                                                                               

is_move_push_and_crush_capture(_,_,_,Counter):- 
		Counter is 0.

%checks if the move causes a normal capture
is_move_normal_capture1(Pos,Player,Counter):- 
	add1_pos(1,Pos,NextPiece), 
	nth0(0,NextPiece,ColumnLetter), 
	nth0(1,NextPiece,Line),                                         
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),       
        Y1 is Line+1 , NextPiece2 =[Column,Y1],
        check_if_player_piece(NextPiece2,Player),                                                            %
        Counter is 1;
        Counter is 0.                                                                                                                             

is_move_normal_capture2(Pos,Player,Counter):-
	add1_pos(4,Pos,NextPiece), 
	nth0(0,NextPiece,ColumnLetter),
	nth0(1,NextPiece,Line),                                          
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),        
        Y1 is Line-1, 
        NextPiece2 =[Column,Y1],
        check_if_player_piece(NextPiece2,Player),                                                             
        Counter is 1;
        Counter is 0.                                                                                                    

is_move_normal_capture3(Pos,Player,Counter):- 
	add1_pos(2,Pos,NextPiece), 
	nth0(0,NextPiece,ColumnLetter), 
	nth0(1,NextPiece,Line),                                         
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),       
        X1 is Column-1 ,
        NextPiece2 =[X1,Line],
        check_if_player_piece(NextPiece2,Player),                                                               
        Counter is 1;
        Counter is 0.                                                                                                      

is_move_normal_capture4(Pos,Player,Counter):- 
	add1_pos(3,Pos,NextPiece), 
	nth0(0,NextPiece,ColumnLetter), 
	nth0(1,NextPiece,Line),                                        
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),        
        X1 is Column+1,
        NextPiece2 =[X1,Line],
        check_if_player_piece(NextPiece2,Player),                                                              
        Counter is 1; 
        Counter is 0.                                                                                                         

/********************************/
%NUMBER 3 PRIORITY
/*******************************/

/**
* Checks if the move causes an attack to the enemy dux
*/
does_move_attack_dux_helper(Pos,Player,Direction):-
	add1_pos(Direction,Pos,NextPiece), 
	nth0(0,NextPiece,ColumnLetter), 
	nth0(1,NextPiece,Line),                                    
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_dux(OppPlayer,Piece).                                   

does_move_attack_dux(Pos,Player):-
	does_move_attack_dux_helper(Pos,Player,1);
        does_move_attack_dux_helper(Pos,Player,2);
        does_move_attack_dux_helper(Pos,Player,3);
        does_move_attack_dux_helper(Pos,Player,4).    