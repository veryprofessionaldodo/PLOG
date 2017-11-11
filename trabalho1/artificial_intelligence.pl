/************************/
/***** AI BEHAVIOUR *****/
/************************/

aI_move(Player, 1):- gather_all_moves([[]|ListOfMoves],Player),!, nonvar(ListOfMoves), length(ListOfMoves,X),X>0,
                random_member(NL, ListOfMoves),create_move(NL, Move),
                move(Move),cls,remove_captured_pieces(Move,Player),is_game_over.

aI_move(Player, 2):- gather_all_moves([[]|ListOfMoves],Player),!, nonvar(ListOfMoves), length(ListOfMoves,X),X>0,
                choose_best_move(ListOfMoves, Player, Move),
                move(Move),cls,remove_captured_pieces(Move,Player),write(Move),write(Player),is_game_over.

create_move(X, Move):-nth0(0,X,X1), column_to_number(Column1, X1),
                nth0(1,X,Y1), 
                nth0(2,X,X2), column_to_number(Column2, X2),
                nth0(3,X,Y2),
                Move=[Column1,Y1,Column2,Y2].

choose_best_move_helper([], _, NL,CurrentBestCapturedPieces, NumberofCaptures, FoundAttackDux):-
                NumberofCaptures>0, NL=CurrentBestCapturedPieces;
                FoundAttackDux\= [],NL=FoundAttackDux.
                 
choose_best_move_helper([Move|T], Player, NL,CurrentBestCapturedPieces, NumberofCaptures, FoundAttackDux):- 
                %create_move(Move, H),does_move_check_mate(H,Player),NL=H;
                create_move(Move, H),move_X_Captured_Pieces(H,Player,Counter), Counter>NumberofCaptures, choose_best_move_helper(T, Player, NL,H, Counter, FoundAttackDux);
                create_move(Move, H),NumberofCaptures<1,nth0(2,H,ColumnLetter), nth0(3,H,Line), Pos=[ColumnLetter,Line],does_move_attack_dux(Pos,Player),choose_best_move_helper(T, Player, NL,CurrentBestCapturedPieces, NumberofCaptures, H);
                choose_best_move_helper(T, Player, NL,CurrentBestCapturedPieces, NumberofCaptures, FoundAttackDux).
                
choose_best_move(ListOfMoves, Player, NL):-choose_best_move_helper(ListOfMoves, Player, NL,[], 0, []).
                                           %random_member(NL, ListOfMoves).

% Gather all moves for all pieces.
gather_all_moves([ListOfMoves|FinalList], Player) :-  board(Board), ListOfMoves = [], gather_moves_recursive(Board, ListOfMoves, 8, Player, FinalList).

% Recursive function that calls itself to see all the pieces.
gather_moves_recursive([Row|Tail], ListOfMoves, RowNumber, Player, FinalList) :- RowNumber > 0, gather_moves_by_row(Row, [], 1, RowNumber,  Player, Tmp2List), 
		NewRow is RowNumber - 1, 
		once(append(Tmp2List, ListOfMoves, NewList)), gather_moves_recursive(Tail, NewList, NewRow, Player, FinalList).

% End of recursion.
gather_moves_recursive(Ending, ListOfMoves, RowNumber, Player, FinalList) :- copy(ListOfMoves, FinalList).

% Gather all pieces in a Row.
gather_moves_by_row([Piece|Tail], ListOfMoves, ColumnNumber, RowNumber, Player, FinalList) :- 
		RowNumber > 0, NewColumn is ColumnNumber + 1,  NewColumn < 12, 
		player_letter(Player, Piece),
		gather_moves_piece(Piece, ColumnNumber, RowNumber, [], TmpList), 
				
		append(TmpList, ListOfMoves, NewList),
		
		gather_moves_by_row(Tail, NewList, NewColumn, RowNumber, Player, FinalList). 

% Gather all pieces in a Row.
gather_moves_by_row([Piece|Tail], ListOfMoves, ColumnNumber, RowNumber, Player, FinalList) :- RowNumber > 0, NewColumn is ColumnNumber + 1, 
		 NewColumn < 12, gather_moves_by_row(Tail, ListOfMoves, NewColumn, RowNumber, Player, FinalList).

% Has reached the ending of row.
gather_moves_by_row(LastNumber, ListOfMoves, ColumnNumber, RowNumber, Player, FinalList) :-
			copy(ListOfMoves, FinalList).

% Gather all moves in a specific place.			
gather_moves_piece(Piece, ColumnNumber, RowNumber, ListOfMoves, FinalList) :- 
		NewRow1 is RowNumber - 1, gather_moves_down(ListOfMoves, ColumnNumber, RowNumber, ColumnNumber, NewRow1, FinalList).

gather_moves_left(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :- 
		get_piece(ColumnNumber, RowNumber, NewPiece), NewPiece == ' ', 
		once(append(ListOfMoves, [[OriginalColumn, OriginalRow, ColumnNumber, RowNumber]], NewList)),
		NewColumn1 is ColumnNumber - 1, NewColumn1 > 0,  
		gather_moves_left(NewList, OriginalColumn, OriginalRow, NewColumn1, OriginalRow, FinalList).

% Has reached the end of column, or hit another piece.
gather_moves_left(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :- 
		NewColumn1 is OriginalColumn + 1, gather_moves_right(ListOfMoves, OriginalRow, OriginalRow, NewColumn1, OriginalRow, FinalList). 

gather_moves_right(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :- 
    	get_piece(ColumnNumber, RowNumber, NewPiece), NewPiece == ' ', 
		NewColumn1 is ColumnNumber + 1, NewColumn1 < 12,
		once(append(ListOfMoves, [[OriginalColumn, OriginalRow, ColumnNumber, RowNumber]], NewList)), 
		gather_moves_right(NewList, OriginalColumn, OriginalRow, NewColumn1, OriginalRow, FinalList).

% Has reached the end of column, or hit another piece.
gather_moves_right(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :- copy(ListOfMoves, FinalList). 

gather_moves_up(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :-
		get_piece(ColumnNumber, RowNumber, NewPiece), NewPiece == ' ', 
		NewRow1 is RowNumber + 1, NewRow1 < 9, 
		once(append(ListOfMoves, [[OriginalColumn, OriginalRow, ColumnNumber, RowNumber]], NewList)), 
		gather_moves_up(NewList, OriginalColumn, OriginalRow, OriginalColumn, NewRow1, FinalList).

% Has reached the end of row, or hit another piece.
gather_moves_up(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :- 
 		NewColumn1 is OriginalColumn - 1, gather_moves_left(ListOfMoves, OriginalColumn, OriginalRow, NewColumn1, OriginalRow, FinalList). 

gather_moves_down(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :-
		NewRow1 is RowNumber - 1, NewRow1 > 0,
		get_piece(ColumnNumber, RowNumber, NewPiece), NewPiece == ' ', 
		once(append(ListOfMoves, [[OriginalColumn, OriginalRow, ColumnNumber, RowNumber]], NewList)),
		gather_moves_down(NewList, OriginalColumn, OriginalRow, OriginalColumn, NewRow1, FinalList).

% Has reached the end of row, or hit another piece.
gather_moves_down(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :- 
		NewRow1 is OriginalRow + 1, gather_moves_up(ListOfMoves, OriginalColumn, OriginalRow, OriginalColumn, NewRow1, FinalList). 

/* ORDEM DE PRIORIDADES 
	1a O Dux inimigo está exposto?
		Se sim, consegue atacar diretamente?
		Se não, consegue dar a volta para o atacar?
	2a O Dux aliado está em perigo?
		Se sim
			O Dux pode-se movimentar para se por em mais segurança?
				Se sim, faze-lo.
				Se não, pôr uma peça entre inimigo que poderá atacar e Dux aliado.
	3a Há algum inimigo que possa ser flanqueado?
		Se sim, flanquear.
	4a Há algum inimigo que possa ser capturado por Testudo (NOTA: Verificar se já existe uma formação existente ou prestes a existir)
		Se sim, capturar.
	5a Há algum inimigo que possa ser capturado por Ataque de Falange?
		Se sim, capturar.
	6a Há alguma peça que possa ser capturada?
		Se sim, capturar.
		Se não, posicionar alguma peça de forma a que possa ser capturada na jogada seguinte.
	7a Fazer uma jogada random.

	Para cada nivel de dificuldade:
		Dificil - Vê a posição de todas as peças, e analisa todas as regras acima.
		Fácil - Vê a posição de 70% das peças, não sabe flanquear, atacar por Testudo, nem Falange. Não sabe defender bem próprio Dux (não põe nenhuma peça no meio, tenta só mexer o Dux).
*/

/****************************/
 %NUMBER 1 PRIORITY               
/***************************/



does_move_check_mate_helper(Move,Player,Direction):-
            nth0(2, Move, PosX), nth0(3, Move, PosY), Pos = [PosX,PosY],
            add1_pos(Direction,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                                    
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),player_dux(OppPlayer,Piece),
	    move(Move),(helper_check_mate(Player,NextPiece),de_move(Move);de_move(Move)).  

does_move_check_mate(Move,Player):-does_move_check_mate_helper(Move,Player,1);
				  does_move_check_mate_helper(Move,Player,2);
				  does_move_check_mate_helper(Move,Player,3);
                                  does_move_check_mate_helper(Move,Player,4).            
%PIECE CAPTURES



/******************************/
%NUMBER 2 PRIORITY
/*****************************/
move_X_Captured_Pieces(Move,Player,Counter):-checks_the_direction_of_move(Move,Direction),
            nth0(2, Move, PosX), nth0(3, Move, PosY), Pos = [PosX,PosY],
            is_move_flank_attack(Pos,Direction,Player,CounterFlank),
            is_move_phalanx_attack(Pos,Direction,Player,CounterPhalanx),
            is_move_push_and_crush_capture(Pos,Direction,Player,CounterPushAndCrush),
            is_move_normal_capture1(Pos,Player,Counter1),is_move_normal_capture2(Pos,Player,Counter2),is_move_normal_capture3(Pos,Player,Counter3),is_move_normal_capture4(Pos,Player,Counter4),
            Counter is CounterFlank+CounterPhalanx+CounterPushAndCrush+Counter1+Counter2+Counter3+Counter4, Counter >0.


is_move_flank_attack(Pos,Direction,Player,Counter):-add1_pos(Direction,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                          %gets the position of the next piece in that direction
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),player_piece(OppPlayer,Piece),        %gets the piece and checks if it's an enemy
            helper_flank_attack(NextPiece,Direction,Player,0),                                                                                            %checks if it follows the flank rule
            Counter is 1.

is_move_flank_attack(_,_,_,Counter):-Counter is 0.

is_move_phalanx_attack(Pos,Direction,Player,Counter):-add1_pos(Direction,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),           %gets the position of the next piece in that direction
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),player_letter(Player,Piece),                               %gets the piece and checks if it's an enemy
            directions_90(Direction,X,_), helper_phalanx_attack(Direction,X,Pos,NextPiece,Player,1),Counter is 1.                                         %gets a perpendicular direction and checks if it follows the rule

is_move_phalanx_attack(Pos,Direction,Player,Counter):-add1_pos(Direction,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),           %gets the position of the next piece in that direction
             column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),player_letter(Player,Piece),                              %gets the piece and checks if it's an enemy
             directions_90(Direction,_,X), helper_phalanx_attack(Direction,X,Pos,NextPiece,Player,1),Counter is 1.                                        %gets the perpendicular direction and checks if it follows the rule

is_move_phalanx_attack(_,_,_,Counter):- Counter is 0.

is_move_push_and_crush_capture(Pos,Direction,Player,Counter):-add1_pos(Direction,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),             %gets the position of the next piece in that direction
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),player_letter(Player,Piece),                                         %gets the piece and checks if it's an ally
            helper_push_and_crush_capture(NextPiece,Direction,Player,1),Counter is 1.                                                                               %checks next position  

is_move_push_and_crush_capture(_,_,_,Counter):- Counter is 0.

is_move_normal_capture1(Pos,Player,Counter):- add1_pos(1,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                                         %Gets position of the upper piece
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),player_piece(OppPlayer,Piece),        %checks if it's an enemy
            Y1 is Line+1 , NextPiece2 =[Column,Y1],check_if_player_piece(NextPiece2,Player),                                                            %checks if the position in that direction is a player's piece or a wall
            Counter is 1;Counter is 0.                                                                                                                               %if it is applies the rule, and checks others directions

is_move_normal_capture2(Pos,Player,Counter):-add1_pos(4,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                                          %Gets position of the left piece
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),player_piece(OppPlayer,Piece),        %checks if it's an enemy
            Y1 is Line-1, NextPiece2 =[Column,Y1],check_if_player_piece(NextPiece2,Player),                                                             %checks if the position in that direction is a player's piece or a wall
            Counter is 1;Counter is 0.                                                                                                    %if it is applies the rule, and checks others directions

is_move_normal_capture3(Pos,Player,Counter):- add1_pos(2,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                                         %Gets position of the right piece
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),player_piece(OppPlayer,Piece),        %checks if it's an enemy
            X1 is Column-1 ,NextPiece2 =[X1,Line],check_if_player_piece(NextPiece2,Player),                                                             %checks if the position in that direction is a player's piece or a wall   
            Counter is 1;Counter is 0.                                                                                                      %if it is applies the rule, and checks others directions

is_move_normal_capture4(Pos,Player,Counter):- add1_pos(3,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                                         %Gets position of the lower piece
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),player_piece(OppPlayer,Piece),        %checks if it's an enemy
            X1 is Column+1,NextPiece2 =[X1,Line],check_if_player_piece(NextPiece2,Player),                                                              %checks if the position in that direction is a player's piece or a wall
            Counter is 1; Counter is 0.                                                                                                           %if it is applies the rule

/********************************/
%NUMBER 3 PRIORITY
/*******************************/

does_move_attack_dux_helper(Pos,Player,Direction):-add1_pos(Direction,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                                    %checks the position 
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),player_dux(OppPlayer,Piece).                                   %and sees if it's a dux 

does_move_attack_dux(Pos,Player):-does_move_attack_dux_helper(Pos,Player,1);
                                  does_move_attack_dux_helper(Pos,Player,2);
                                  does_move_attack_dux_helper(Pos,Player,3);
                                  does_move_attack_dux_helper(Pos,Player,4).    