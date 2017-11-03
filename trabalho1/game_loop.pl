:- reconsult(utils).
:- reconsult(interface).
:- use_module(library(lists)).

/* BEGINNING OF GAME */

latrunculli:- write('Which type of game do you want to play? \n 1 - Player Versus Player \n 2 - Player Versus AI \n 3 - AI Versus AI\n'),
            read(ReadMode), playMode(ReadMode).

/* Starts a new game in pvp. */
playMode(1) :-  clear_global_variables, print_board, nl, write('Good luck to both!\n'), print_make_move, nl, play(1), nl.

/* Starts a new game in pvAI. */
playMode(2) :-  clear_global_variables, print_board, nl, write('Good luck!\n'), print_make_move, nl, play(2), nl.

/* Starts a new game in AIvAI. */
playMode(3) :-  clear_global_variables, print_board, nl, write('Watch it all unfold before you!\n'), print_make_move, nl, play(3), nl.

/* Invalid game mode. */
playMode(_) :-  write('Invalid game type! Try again. \n 1 - Player Versus Player \n 2 - Player Versus AI \n 3 - AI Versus AI \n'),
			read(ReadMode), playMode(ReadMode).


clear_global_variables :- retractall(board(_)), initial_board(StartBoard), assert(board(StartBoard)), retractall(playcounter(_)), assert(playcounter(100)).

/* THE GAME LOOP */

/* Game Loop, in pvp. */
play(1) :- read_move(1), print_board, read_move(2), print_board, play(1).

/* Game Loop in pvAI. */
play(2) :- print_board.

/* Game Loop in AIvAI. */
play(3) :- print_board.

%* Reads move for a player passed in argument. 
read_move(X):- write('Make your move Player '), write(X), nl, read(MoveString), string_to_move(MoveString, Move), check_if_valid(Move, X),
	move(Move),is_game_over.

read_move(Y):- write('Invalid move! Do a new valid move.\n'), read_move(Y).

%Checks if the game ended
is_game_over:-board(Board), check_soldiers_and_Dux(Board,0,0,0,0), 
            playcounter(X), X>0 , Y is X-1, retract(playcounter(X)), assert(playcounter(Y)). %atualiza número de jogadas restantes


check_soldiers_and_Dux(_,1,1,1,1).   % tudo normal continuar normalmente

check_soldiers_and_Dux(T,Pb,PB,Pw,PW):- 
            length(T, 1), Pb=0, write('Player 2 Lost \n'),
            !, fail;
            length(T, 1), PB=0, write('Player 2 Lost \n');
            length(T, 1), Pw=0, write('Player 1 Lost \n');
            length(T, 1), PW=0, write('Player 1 Lost \n'),
            !, fail.

check_soldiers_and_Dux([H|T],Pb,PB,Pw,PW):-check_soldiers_and_Dux_Row(H,Pb,PB,Pw,PW,T). % dá check nas filas 1 a 1 por peças

check_soldiers_and_Dux_Row(T,Pb,PB,Pw,PW,X):- length(T, 1),check_soldiers_and_Dux(X,Pb,PB,Pw,PW). % acabou fila atual passa para a próxima

check_soldiers_and_Dux_Row([H|T],Pb,PB,Pw,PW,X):-
            H = 'b',check_soldiers_and_Dux_Row(T,1,PB,Pw,PW,X);
            H = 'B',check_soldiers_and_Dux_Row(T,Pb,1,Pw,PW,X);
            H = 'w',check_soldiers_and_Dux_Row(T,Pb,PB,1,PW,X);
            H = 'W',check_soldiers_and_Dux_Row(T,Pb,PB,Pw,1,X);
            H = ' ',check_soldiers_and_Dux_Row(T,Pb,PB,Pw,PW,X).

% Check whether play is valid for a specific player. 
check_if_valid(Move, Player) :- is_own_piece(Move, Player), attempt_to_move(Move).

 /*Moves a PIECE*/
move(Move):-board(Board),
        nth0(0, Move, ColumnPieceToMove), nth0(1, Move, LinePieceToMove),get_piece(Board,ColumnPieceToMove,LinePieceToMove,Piece),                  %gets the piece on a given position
        nth0(2, Move, ColumnNewPos), nth0(3, Move, LineNewPos), set_piece(ColumnNewPos,LineNewPos,Piece),                                           %moves it to the new position
        set_piece(ColumnPieceToMove,LinePieceToMove,' ').  

% Sees what piece is in position. 
get_piece(Board,Column,Line,Piece):- column_to_number(Column, ColumnNumber), line_to_position(Line, LineNumber),
                nth1(LineNumber, Board, X), nth1(ColumnNumber, X, Piece).

% Replaces a character in a given position on the board.
set_piece(ColumnLetter,Line,Piece):- column_to_number(ColumnLetter, ColumnNumber), 
        line_to_position(Line, LineNumber),                                   
        board(Board),
        replace(Board,LineNumber,ColumnNumber,Piece,NewBoard),
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

  






