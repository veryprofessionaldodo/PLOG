/************************/
/***** AI BEHAVIOUR *****/
/************************/

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
        is_game_over.

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
        is_game_over.

create_move(X, Move):-
		nth0(0,X,X1), 
		column_to_number(Column1, X1),
        nth0(1,X,Y1), 
        nth0(2,X,X2),
        column_to_number(Column2, X2),
        nth0(3,X,Y2),
        Move=[Column1,Y1,Column2,Y2].

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
        NumberofCaptures<1,nth0(2,H,ColumnLetter), 
        nth0(3,H,Line), Pos=[ColumnLetter,Line],
        does_move_attack_dux(Pos,Player),
        choose_best_move_helper(T, Player, NL,CurrentBestCapturedPieces, NumberofCaptures, H);
        choose_best_move_helper(T, Player, NL,CurrentBestCapturedPieces, NumberofCaptures, FoundAttackDux).
                
choose_best_move(ListOfMoves, Player, NL):-
		random_permutation(ListOfMoves, NewRandomList),
		choose_best_move_helper(NewRandomList, Player, NL,[], 0, []);
        random_member(Move, ListOfMoves),
        create_move(Move, NL).

% Gather all moves for all pieces.
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
gather_moves_recursive(Ending, ListOfMoves, RowNumber, Player, FinalList) :- 
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
gather_moves_by_row([Piece|Tail], ListOfMoves, ColumnNumber, RowNumber, Player, FinalList) :- 
		RowNumber > 0, 
		NewColumn is ColumnNumber + 1, 
		NewColumn < 12, 
		gather_moves_by_row(Tail, ListOfMoves, NewColumn, RowNumber, Player, FinalList).

% Has reached the ending of row.
gather_moves_by_row(LastNumber, ListOfMoves, ColumnNumber, RowNumber, Player, FinalList) :-
			copy(ListOfMoves, FinalList).

% Gather all moves in a specific place.			
gather_moves_piece(Piece, ColumnNumber, RowNumber, ListOfMoves, FinalList) :- 
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
gather_moves_left(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :- 
		NewColumn1 is OriginalColumn + 1, 
		gather_moves_right(ListOfMoves, OriginalRow, OriginalRow, NewColumn1, OriginalRow, FinalList). 

gather_moves_right(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :- 
    	get_piece(ColumnNumber, RowNumber, NewPiece), 
    	NewPiece == ' ', 
		NewColumn1 is ColumnNumber + 1, 
		NewColumn1 < 12,
		column_to_number(OriginalColumnLetter, OriginalColumn),
		column_to_number(ColumnNumberLetter, ColumnNumber),
		check_piece_warfare([OriginalColumnLetter, OriginalRow, ColumnNumberLetter, RowNumber]),
		gather_moves_right(NewList, OriginalColumn, OriginalRow, NewColumn1, OriginalRow, FinalList).

% Has reached the end of column, or hit another piece.
gather_moves_right(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :- 
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
gather_moves_up(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :- 
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
gather_moves_down(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber, FinalList) :- 
		NewRow1 is OriginalRow + 1, 
		gather_moves_up(ListOfMoves, OriginalColumn, OriginalRow, OriginalColumn, NewRow1, FinalList). 

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
	    	(helper_check_mate(Player,NextPiece),
	    	de_move(Move) ;
	    	de_move(Move),fail).  

does_move_check_mate(Move,Player):-does_move_check_mate_helper(Move,Player,1);
		does_move_check_mate_helper(Move,Player,2);
		does_move_check_mate_helper(Move,Player,3);
        does_move_check_mate_helper(Move,Player,4).            
%PIECE CAPTURES


/******************************/
%NUMBER 2 PRIORITY
/*****************************/
%flank rule
helper_flank_attack(Pos,Direction,Player,1):- 
        add1_pos(Direction,Pos,NextPiece),
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),           %gets the position of the next piece in that direction
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        player_letter(Player,Piece).                                    %gets the piece and checks if it's player's piece, if it does follows the rule

helper_flank_attack(Pos,Direction,Player,_):- 
        add1_pos(Direction,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),                  %gets the position of the next piece in that direction
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_letter(OppPlayer,Piece),       %gets the piece and checks if it's an enemy
        helper_flank_attack(NextPiece,Direction,Player,1).                                                                                            %recurse it down

flank_attack(Pos,Direction,Player):-
        add1_pos(Direction,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),                          %gets the position of the next piece in that direction
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),        %gets the piece and checks if it's an enemy
        helper_flank_attack(NextPiece,Direction,Player,0),                                                                                            %checks if it follows the flank rule
        set_piece(ColumnLetter,Line,' '), 
        format('Player ~w Piece at ~w~w got captured ~n~n',[Player,ColumnLetter,Line]).                                                                                                           % if it does eliminates it

flank_attack(_,_,_).

%phalanx/testudo rule
helper_phalanx_attack(Direction, Direction2, Pos,NextPiece,Player,1):-
        add1_pos(Direction2,Pos,NextPieceForPhalanx), 
        nth0(0,NextPieceForPhalanx,ColumnPhalanxLetter), 
        nth0(1,NextPieceForPhalanx,LinePhalanx),         %gets the position of the piece in the perpendicular direction
        column_to_number(ColumnPhalanxLetter, ColumnPhalanx),
        get_piece(ColumnPhalanx,LinePhalanx,Piece),
        player_letter(Player,Piece),                    %gets the piece and checks if it's a player's piece
        add1_pos(Direction,NextPiece,NextPieceForPhalanx2),
        nth0(0,NextPieceForPhalanx2,ColumnLetter), 
        nth0(1,NextPieceForPhalanx2,Line),               %gets the position of the piece in the direction of the move
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece2),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece2).          %gets the piece and checks if it's an enemy


helper_phalanx_attack(Direction, Direction2, Pos,NextPiece,Player,0):-
        add1_pos(Direction2,Pos,NextPieceForPhalanx), 
        nth0(0,NextPieceForPhalanx,ColumnPhalanxLetter), 
        nth0(1,NextPieceForPhalanx,LinePhalanx),         %gets the position of the piece in the perpendicular direction
        column_to_number(ColumnPhalanxLetter, ColumnPhalanx),
        get_piece(ColumnPhalanx,LinePhalanx,Piece),
        player_letter(Player,Piece),                    %gets the piece and checks if it's a player's piece
        add1_pos(Direction,NextPiece,NextPieceForPhalanx2), 
        nth0(0,NextPieceForPhalanx2,ColumnLetter), 
        nth0(1,NextPieceForPhalanx2,Line),               %gets the position of the piece in the direction of the move
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece2),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece2),          %gets the piece and checks if it's an enemy
        set_piece(ColumnLetter,Line,' '), 
        format('Player ~w Piece at ~w~w got captured ~n~n',[Player,ColumnLetter,Line]).                                                                                                                %if it is follows the rule

helper_phalanx_attack(Direction, Direction2, Pos,NextPiece,Player,Type):-
        add1_pos(Direction2,Pos,NextPieceForPhalanx), 
        nth0(0,NextPieceForPhalanx,ColumnPhalanxLetter), 
        nth0(1,NextPieceForPhalanx,LinePhalanx),         %gets the position of the piece in the perpendicular direction
        column_to_number(ColumnPhalanxLetter, ColumnPhalanx),
        get_piece(ColumnPhalanx,LinePhalanx,Piece),
        player_letter(Player,Piece),                    %gets the piece and checks if it's a player's piece
        add1_pos(Direction,NextPiece,NextPieceForPhalanx2), 
        nth0(0,NextPieceForPhalanx2,ColumnLetter), 
        nth0(1,NextPieceForPhalanx2,Line),               %gets the position of the piece in the direction of the move
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece2),
        player_letter(Player,Piece2),                                              %gets the piece and checks if it's a player's piece
        helper_phalanx_attack(Direction,Direction2,NextPiece,NextPieceForPhalanx2,Player,Type).                                                              %recurse it down

phalanx_attack(Pos,Direction,Player):-
        add1_pos(Direction,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),           %gets the position of the next piece in that direction
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        player_letter(Player,Piece),                               %gets the piece and checks if it's an enemy
        directions_90(Direction,X,_),
        helper_phalanx_attack(Direction,X,Pos,NextPiece,Player,0).                                         %gets a perpendicular direction and checks if it follows the rule

phalanx_attack(Pos,Direction,Player):-
        add1_pos(Direction,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),           %gets the position of the next piece in that direction
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        player_letter(Player,Piece),                              %gets the piece and checks if it's an enemy
        directions_90(Direction,_,X), 
        helper_phalanx_attack(Direction,X,Pos,NextPiece,Player,0).                                        %gets the perpendicular direction and checks if it follows the rule

phalanx_attack(_,_,_).


%push and crush capture
helper_push_and_crush_capture2(Pos,Direction,Player):- 
        add1_pos(Direction,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),                         %gets the position of the next piece in that direction
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        (player_letter(OppPlayer,Piece);
            equal(Piece,' ')).      %gets the piece and checks if it's an enemy or empty space

                                 
helper_push_and_crush_capture(Pos,Direction,Player,0):- 
        add1_pos(Direction,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),      %gets the position of the next piece in that direction
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),      %gets the piece and checks if it's an enemy
        \+ helper_push_and_crush_capture2(NextPiece,Direction,Player),                                                                            %checks if the next piece is an enemy if it isn't follows the rule              
        set_piece(ColumnLetter,Line,' '), 
        format('Player ~w Piece at ~w~w got captured ~n~n',[Player,ColumnLetter,Line]).                                                                                                          %removes captured piece

helper_push_and_crush_capture(Pos,Direction,Player,1):- 
        add1_pos(Direction,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),      %gets the position of the next piece in that direction
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),      %gets the piece and checks if it's an enemy
        \+ helper_push_and_crush_capture2(NextPiece,Direction,Player).                                                                            %checks if the next piece is an enemy if it isn't follows the rule              


push_and_crush_capture(Pos,Direction,Player):-
        add1_pos(Direction,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),             %gets the position of the next piece in that direction
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),player_letter(Player,Piece),                                         %gets the piece and checks if it's an ally
        helper_push_and_crush_capture(NextPiece,Direction,Player,0).                                                                               %checks next position                          

push_and_crush_capture(_,_,_).


%normal capture


%if it is a player's piece follows the rule
check_if_player_piece(NextPiece,Player):- 
        nth0(0,NextPiece,Column), 
        nth0(1,NextPiece,Line), 
        get_piece(Column,Line,Piece),
        player_letter(Player,Piece).

normal_capture(Pos,Player):- 
        add1_pos(1,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),                                         %Gets position of the upper piece
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),        %checks if it's an enemy
        Y1 is Line+1 , 
        NextPiece2 =[Column,Y1],
        check_if_player_piece(NextPiece2,Player),                                                            %checks if the position in that direction is a player's piece or a wall
        set_piece(ColumnLetter,Line,' '), 
        format('Player ~w Piece at ~w~w got captured ~n~n',[Player,ColumnLetter,Line]), fail.                                                                                                      %if it is applies the rule, and checks others directions

normal_capture(Pos,Player):-
        add1_pos(4,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),                                          %Gets position of the left piece
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),        %checks if it's an enemy
        Y1 is Line-1, 
        NextPiece2 =[Column,Y1],
        check_if_player_piece(NextPiece2,Player),                                                             %checks if the position in that direction is a player's piece or a wall
        set_piece(ColumnLetter,Line,' '), 
        format('Player ~w Piece at ~w~w got captured ~n~n',[Player,ColumnLetter,Line]),fail.                                                                                                      %if it is applies the rule, and checks others directions

normal_capture(Pos,Player):- 
        add1_pos(2,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),                                         %Gets position of the right piece
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),        %checks if it's an enemy
        X1 is Column-1 ,
        NextPiece2 =[X1,Line],
        check_if_player_piece(NextPiece2,Player),                                                             %checks if the position in that direction is a player's piece or a wall   
        set_piece(ColumnLetter,Line,' '), 
        format('Player ~w Piece at ~w~w got captured ~n~n',[Player,ColumnLetter,Line]),fail.                                                                                                      %if it is applies the rule, and checks others directions

normal_capture(Pos,Player):- 
        add1_pos(3,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),                                         %Gets position of the lower piece
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),        %checks if it's an enemy
        X1 is Column+1,
        NextPiece2 =[X1,Line],
        check_if_player_piece(NextPiece2,Player),                                                              %checks if the position in that direction is a player's piece or a wall
        set_piece(ColumnLetter,Line,' '), 
        format('Player ~w Piece at ~w~w got captured ~n~n',[Player,ColumnLetter,Line]).                                                                                                           %if it is applies the rule
            

normal_capture(_,_).

%Did the Dux get captured
%checks if the dux has atleast one enemy around him
is_Dux_in_Guerrilla(Player,DuxPos):-
        add1_pos(1,DuxPos,NextPieceUp), 
        nth0(0,NextPieceUp,ColumnLetterUp), 
        nth0(1,NextPieceUp,LineUp),                           
        column_to_number(ColumnLetterUp, ColumnUp),
        get_piece(ColumnUp,LineUp,PieceUp),
        opposing_player(Player,OppPlayer1),
        player_letter(OppPlayer1,PieceUp);
        add1_pos(4,DuxPos,NextPieceDown), 
        nth0(0,NextPieceDown,ColumnLetterDown), 
        nth0(1,NextPieceDown,LineDown),                           
        column_to_number(ColumnLetterDown, ColumnDown),
        get_piece(ColumnDown,LineDown,PieceDown),
        pposing_player(Player,OppPlayer4),
        player_letter(OppPlayer4,PieceDown);
        add1_pos(2,DuxPos,NextPieceLeft), 
        nth0(0,NextPieceLeft,ColumnLetterLeft), 
        nth0(1,NextPieceLeft,LineLeft),                           
        column_to_number(ColumnLetterLeft, ColumnLeft),
        get_piece(ColumnLeft,LineLeft,PieceLeft),
        opposing_player(Player,OppPlayer2),
        player_letter(OppPlayer2,PieceLeft);
        add1_pos(3,DuxPos,NextPieceRight), 
        nth0(0,NextPieceRight,ColumnLetterRight), 
        nth0(1,NextPieceRight,LineRight),                           
        column_to_number(ColumnLetterRight, ColumnRight),
        get_piece(ColumnRight,LineRight,PieceRight),
        opposing_player(Player,OppPlayer3),
        player_letter(OppPlayer3,PieceRight).
                                    
check_mate_check_piece_or_wall(Player,NextPiece,DuxPos):-            %checks if it's a wall if it is checks if the dux has atleast one enemy around him
        nth0(0,NextPiece,Column),
        Column>10, 
        is_Dux_in_Guerrilla(Player,DuxPos);
        nth0(0,NextPiece,Column), 
        Column<1, 
        is_Dux_in_Guerrilla(Player,DuxPos);
        nth0(1,NextPiece,Line), 
        Line>8, 
        is_Dux_in_Guerrilla(Player,DuxPos);
        nth0(1,NextPiece,Line), 
        Line<1, 
        is_Dux_in_Guerrilla(Player,DuxPos).


check_mate_check_piece_or_wall(_,NextPiece,_):-
        nth0(0,NextPiece,Column), 
        nth0(1,NextPiece,Line),                           %checks if it's a piece
        get_piece(Column,Line,Piece),
        player_letter(_,Piece).
            
helper_check_mate(Player,DuxPos):- 
        nth0(0,DuxPos,ColumnLetterUp), 
        nth0(1,DuxPos,LineUp),  
        column_to_number(ColumnLetterUp, ColumnUp), 
        Y1 is LineUp+1 , 
        NextPieceUp =[ColumnUp,Y1],                     %checks the upper position 
        check_mate_check_piece_or_wall(Player,NextPieceUp,DuxPos),                                                                                                          %and checks if it's a piece or wall
        nth0(0,DuxPos,ColumnLetterDown), 
        nth0(1,DuxPos,LineDown),  
        column_to_number(ColumnLetterDown, ColumnDown), 
        Y2 is LineDown-1 , 
        NextPieceDown =[ColumnDown,Y2],       %checks the bottom position
        check_mate_check_piece_or_wall(Player,NextPieceDown,DuxPos),                                                                                                        %and checks if it's a piece or wall
        nth0(0,DuxPos,ColumnLetterLeft), 
        nth0(1,DuxPos,LineLeft),  
        column_to_number(ColumnLetterLeft, ColumnLeft), X1 is ColumnLeft-1 ,NextPieceLeft =[X1,LineLeft],        %checks the position to the left
        check_mate_check_piece_or_wall(Player,NextPieceLeft,DuxPos),                                                                                                        %and checks if it's a piece or wall
        nth0(0,DuxPos,ColumnLetterRight),
        nth0(1,DuxPos,LineRight),  
        column_to_number(ColumnLetterRight, ColumnRight), X2 is ColumnRight+1 , NextPieceRight =[X2,LineRight],    %checks the position to the right
        check_mate_check_piece_or_wall(Player,NextPieceRight,DuxPos).                                                                                                           %and checks if it's a piece or wall
        

check_mate(Pos):-
        add1_pos(1,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),                                                                             %checks the upper position 
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        player_dux(Player,Piece),
        helper_check_mate(Player,NextPiece),
        set_piece(ColumnLetter,Line,' '),  %and sees if it's a dux
        format('Player ~w Dux at ~w~w got immobilized ~n~n',[Player,ColumnLetter,Line]).

check_mate(Pos):-
        add1_pos(4,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),                                                                             %checks the bottom position
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        player_dux(Player,Piece),
        helper_check_mate(Player,NextPiece),
        set_piece(ColumnLetter,Line,' '),  %and sees if it's a dux 
        format('Player ~w Dux at ~w~w got immobilized ~n~n',[Player,ColumnLetter,Line]).                                                                                                                    

check_mate(Pos):-
        add1_pos(2,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),                                                                             %checks the position to the left
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        player_dux(Player,Piece),
        helper_check_mate(Player,NextPiece),
        set_piece(ColumnLetter,Line,' '),  %and sees if it's a dux 
        format('Player ~w Dux at ~w~w got immobilized ~n~n',[Player,ColumnLetter,Line]). 

check_mate(Pos):-
        add1_pos(3,Pos,NextPiece), 
        nth0(0,NextPiece,ColumnLetter), 
        nth0(1,NextPiece,Line),                                                                             %checks the position to the right
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        player_dux(Player,Piece),
        helper_check_mate(Player,NextPiece),
        set_piece(ColumnLetter,Line,' '),  %and sees if it's a dux 
        format('Player ~w Dux at ~w~w got immobilized ~n~n',[Player,ColumnLetter,Line]).   
            
check_mate(_).

/****************************/
/*******GAME OVER Predicates*/
/****************************/
%Checks if the game ended
is_game_over:-board(Board), check_soldiers_and_Dux(Board,0,0,0,0),
        playcounter(X), X>0 , 
        Y is X-1, 
        retract(playcounter(X)), 
        assert(playcounter(Y)), 
        check_possible_moves. %atualiza n?mero de jogadas restantes

is_game_over:-
        cls, print_board, 
        write('\n The game ended with a draw. \n'), break.

check_possible_moves:-
        gather_all_moves([[]|ListOfMoves],1), 
        nonvar(ListOfMoves), 
        length(ListOfMoves,X),X>0,
        gather_all_moves([[]|ListOfMoves2],2), 
        nonvar(ListOfMoves2), 
        length(ListOfMoves2,Y),Y>0.

check_possible_moves:- 
        gather_all_moves([[]|ListOfMoves],1), 
        nonvar(ListOfMoves), 
        length(ListOfMoves,X),
        X<1,
        write('\n Player 1 Lost, there is possible move \n'), break.
                       
check_possible_moves:- 
        gather_all_moves([[]|ListOfMoves],2), 
        nonvar(ListOfMoves), 
        length(ListOfMoves,X),
        X<1,
        write('\n Player 2 Lost, there is possible move \n'), break. 

%checks if one of the players lost
check_soldiers_and_Dux(_,1,1,1,1).   % tudo normal continuar normalmente

check_soldiers_and_Dux(T,Pb,PB,Pw,PW):- 
        length(T, 1), 
        Pb=0, 
        cls, print_board, 
        write('\n Player 2 Lost, there is no more soldiers \n'), break;
        length(T, 1), 
        PB=0, 
        cls, print_board, 
        write('\n Player 2 Lost, you lost your Dux \n'), break;
        length(T, 1), 
        Pw=0, 
        cls, print_board, 
        write('\n Player 1 Lost, there is no more soldiers \n'), break;
        length(T, 1), 
        PW=0,
        cls, print_board, 
        write('\n Player 1 Lost, you lost your Dux \n'), break.

check_soldiers_and_Dux([H|T],Pb,PB,Pw,PW):-
        check_soldiers_and_Dux_Row(H,Pb,PB,Pw,PW,T). % d?check nas filas 1 a 1 por pe?s

check_soldiers_and_Dux_Row(T,Pb,PB,Pw,PW,X):- 
        length(T, 1),
        check_soldiers_and_Dux(X,Pb,PB,Pw,PW). % acabou fila atual passa para a pr?ima

check_soldiers_and_Dux_Row([H|T],Pb,PB,Pw,PW,X):-
        H = 'b',check_soldiers_and_Dux_Row(T,1,PB,Pw,PW,X);
        H = 'B',check_soldiers_and_Dux_Row(T,Pb,1,Pw,PW,X);
        H = 'w',check_soldiers_and_Dux_Row(T,Pb,PB,1,PW,X);
        H = 'W',check_soldiers_and_Dux_Row(T,Pb,PB,Pw,1,X);
        H = ' ',check_soldiers_and_Dux_Row(T,Pb,PB,Pw,PW,X).

% Check whether play is valid for a specific player. 
check_if_valid(Move, Player) :- 
        is_own_piece(Move, Player), 
        attempt_to_move(Move).


/*********************************/
/****** MOVE GET AND SET*********/
/*******************************/

move(Move):- 
        nth0(0, Move, ColumnLetter), 
        nth0(1, Move, LinePieceToMove), 
        column_to_number(ColumnLetter, ColumnPieceToMove),
        get_piece(ColumnPieceToMove,LinePieceToMove,Piece),                 %gets the piece on a given position
        nth0(2, Move, ColumnNewPosLetter), 
        nth0(3, Move, LineNewPos),
        set_piece(ColumnNewPosLetter,LineNewPos,Piece),                            %moves it to the new position 
        set_piece(ColumnLetter,LinePieceToMove,' ').   

de_move(Move):-
        nth0(2, Move, ColumnLetter), 
        nth0(3, Move, LinePieceToMove), 
        column_to_number(ColumnLetter, ColumnPieceToMove),
        get_piece(ColumnPieceToMove,LinePieceToMove,Piece),                 %gets the piece on a given position
        nth0(0, Move, ColumnNewPosLetter), 
        nth0(1, Move, LineNewPos),
        set_piece(ColumnNewPosLetter,LineNewPos,Piece),                            %moves it to the new position 
        set_piece(ColumnLetter,LinePieceToMove,' ').   

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


is_move_flank_attack(Pos,Direction,Player,Counter):-
		add1_pos(Direction,Pos,NextPiece), 
		nth0(0,NextPiece,ColumnLetter), 
		nth0(1,NextPiece,Line),                          %gets the position of the next piece in that direction
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),        %gets the piece and checks if it's an enemy
        helper_flank_attack(NextPiece,Direction,Player,0),                                                                                            %checks if it follows the flank rule
        Counter is 1.

is_move_flank_attack(_,_,_,Counter):-Counter is 0.

is_move_phalanx_attack(Pos,Direction,Player,Counter):-
		add1_pos(Direction,Pos,NextPiece), 
		nth0(0,NextPiece,ColumnLetter), 
		nth0(1,NextPiece,Line),           %gets the position of the next piece in that direction
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        player_letter(Player,Piece),                               %gets the piece and checks if it's an enemy
        directions_90(Direction,X,_), 
        helper_phalanx_attack(Direction,X,Pos,NextPiece,Player,1),
        Counter is 1.                                         %gets a perpendicular direction and checks if it follows the rule

is_move_phalanx_attack(Pos,Direction,Player,Counter):-
		add1_pos(Direction,Pos,NextPiece), 
		nth0(0,NextPiece,ColumnLetter), 
		nth0(1,NextPiece,Line),           %gets the position of the next piece in that direction
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        player_letter(Player,Piece),                              %gets the piece and checks if it's an enemy
        directions_90(Direction,_,X), 
        helper_phalanx_attack(Direction,X,Pos,NextPiece,Player,1),
        Counter is 1.                                        %gets the perpendicular direction and checks if it follows the rule

is_move_phalanx_attack(_,_,_,Counter):- 
		Counter is 0.

is_move_push_and_crush_capture(Pos,Direction,Player,Counter):-
		add1_pos(Direction,Pos,NextPiece), 
		nth0(0,NextPiece,ColumnLetter), 
		nth0(1,NextPiece,Line),             %gets the position of the next piece in that direction
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        player_letter(Player,Piece),                                         %gets the piece and checks if it's an ally
        helper_push_and_crush_capture(NextPiece,Direction,Player,1),
        Counter is 1.                                                                               %checks next position  

is_move_push_and_crush_capture(_,_,_,Counter):- 
		Counter is 0.

is_move_normal_capture1(Pos,Player,Counter):- 
		add1_pos(1,Pos,NextPiece), 
		nth0(0,NextPiece,ColumnLetter), 
		nth0(1,NextPiece,Line),                                         %Gets position of the upper piece
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),        %checks if it's an enemy
        Y1 is Line+1 , NextPiece2 =[Column,Y1],
        check_if_player_piece(NextPiece2,Player),                                                            %checks if the position in that direction is a player's piece or a wall
        Counter is 1;
        Counter is 0.                                                                                                                               %if it is applies the rule, and checks others directions

is_move_normal_capture2(Pos,Player,Counter):-
		add1_pos(4,Pos,NextPiece), 
		nth0(0,NextPiece,ColumnLetter),
		nth0(1,NextPiece,Line),                                          %Gets position of the left piece
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),        %checks if it's an enemy
        Y1 is Line-1, 
        NextPiece2 =[Column,Y1],
        check_if_player_piece(NextPiece2,Player),                                                             %checks if the position in that direction is a player's piece or a wall
        Counter is 1;
        Counter is 0.                                                                                                    %if it is applies the rule, and checks others directions

is_move_normal_capture3(Pos,Player,Counter):- 
		add1_pos(2,Pos,NextPiece), 
		nth0(0,NextPiece,ColumnLetter), 
		nth0(1,NextPiece,Line),                                         %Gets position of the right piece
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),        %checks if it's an enemy
        X1 is Column-1 ,
        NextPiece2 =[X1,Line],
        check_if_player_piece(NextPiece2,Player),                                                             %checks if the position in that direction is a player's piece or a wall   
        Counter is 1;
        Counter is 0.                                                                                                      %if it is applies the rule, and checks others directions

is_move_normal_capture4(Pos,Player,Counter):- 
		add1_pos(3,Pos,NextPiece), 
		nth0(0,NextPiece,ColumnLetter), 
		nth0(1,NextPiece,Line),                                         %Gets position of the lower piece
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_piece(OppPlayer,Piece),        %checks if it's an enemy
        X1 is Column+1,
        NextPiece2 =[X1,Line],
        check_if_player_piece(NextPiece2,Player),                                                              %checks if the position in that direction is a player's piece or a wall
        Counter is 1; 
        Counter is 0.                                                                                                           %if it is applies the rule

/********************************/
%NUMBER 3 PRIORITY
/*******************************/

does_move_attack_dux_helper(Pos,Player,Direction):-
		add1_pos(Direction,Pos,NextPiece), 
		nth0(0,NextPiece,ColumnLetter), 
		nth0(1,NextPiece,Line),                                    %checks the position 
        column_to_number(ColumnLetter, Column),
        get_piece(Column,Line,Piece),
        opposing_player(Player,OppPlayer),
        player_dux(OppPlayer,Piece).                                   %and sees if it's a dux 

does_move_attack_dux(Pos,Player):-
		does_move_attack_dux_helper(Pos,Player,1);
        does_move_attack_dux_helper(Pos,Player,2);
        does_move_attack_dux_helper(Pos,Player,3);
        does_move_attack_dux_helper(Pos,Player,4).    