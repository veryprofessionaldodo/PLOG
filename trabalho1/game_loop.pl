:- reconsult(utils).
:- reconsult(interface).
:- reconsult(game_logic).
:- reconsult(artificial_intelligence).
:- use_module(library(random)).
:- use_module(library(lists)).
:- use_module(library(system)).

/****************************/
/*****BEGINNING OF GAME *****/
/****************************/

latrunculli:- cls, write('LATRUNCULLI \n \n Which type of game do you want to play? \n 1 - Player Versus Player \n 2 - Player Versus AI \n 3 - AI Versus AI\n'),
            read(ReadMode), playMode(ReadMode).

/* Starts a new game in pvp. */
playMode(1) :-  clear_global_variables, cls,  write('Good luck to both!\n\n'), print_board, nl, print_make_move, nl, !, play(1,0,0), nl.

/* Starts a new game in pvAI. */
playMode(2) :-  clear_global_variables, cls, write('Good luck!\n\n'), !, get_level_ai(Level,0), cls, print_board, nl, print_make_move, nl,play(2,Level,0), nl.

/* Starts a new game in AIvAI. */
playMode(3) :-  clear_global_variables, cls, write('Watch it all unfold before you!\n\n'), nl, !,get_level_ai(Level1,1), get_level_ai(Level2,2), cls, print_board,nl, play(3,Level1,Level2), nl.

/* Invalid game mode. */

playMode(_) :-  write('Invalid game type! Try again. \n 1 - Player Versus Player \n 2 - Player Versus AI \n 3 - AI Versus AI \n'),
			read(ReadMode), playMode(ReadMode).

clear_global_variables :- retractall(board(_)), initial_board(StartBoard), assert(board(StartBoard)), 
            retractall(playcounter(_)), assert(playcounter(101)).

get_level_ai(Level,0):- write('\n AI LEVEL \n \n Which type of AI do you want to use? \n 1 - Random \n 2 - Intelligent AI \n'),read(Level).

get_level_ai(Level,AiNumber):- format('\n AI LEVEL \n \n Which type of AI do you want to use for Player ~w? \n 1 - Random \n 2 - Intelligent AI \n',[AiNumber]),read(Level).


/****************************/
/********THE GAME LOOP ******/
/****************************/

/* Game Loop, in pvp. */
play(1,0,0) :-  read_move(1), print_board, %l?jogada jogador 1      
                read_move(2), print_board, %l?jogada jogador 2
                play(1,0,0). %chamada recursiva

/* Game Loop in pvAI. */
play(2,LevelAi,0):- read_move(1), print_board,
                    sleep(2), aI_move(2, LevelAi), print_board, write('Player 2 finished playing\n'), sleep(1),
                    play(2,LevelAi,0).
 
/* Game Loop in AIvAI. */
play(3,LevelAi1,LevelAi2):- sleep(2), write('Player 1 is thinking...\n'), aI_move(1, LevelAi1), print_board,  write('Player 1 finished playing\n'), sleep(1),
                            sleep(2), write('Player 2 is thinking...\n'), aI_move(2, LevelAi2),print_board,  write('Player 2 finished playing\n'), sleep(1), 
                            play(3,LevelAi1,LevelAi2).

%* Reads move for a player passed in argument. 
read_move(X):- write('Make your move Player '), write(X), nl, read(MoveString), string_to_move(MoveString, Move), check_if_valid(Move, X), !,
	move(Move),cls,remove_captured_pieces(Move,X),is_game_over.

read_move(Y):- write('Invalid move! Do a new valid move.\n'), read_move(Y).


/*****************************/
/****Removes captured PIECES*/
/****************************/

remove_captured_pieces(Move,Player) :- checks_the_direction_of_move(Move,Direction),
            nth0(2, Move, PosX), nth0(3, Move, PosY), Pos = [PosX,PosY],
            flank_attack(Pos,Direction,Player),
            phalanx_attack(Pos,Direction,Player),
            push_and_crush_capture(Pos,Direction,Player),
            normal_capture(Pos,Player),
            check_mate(Pos).


%flank rule
helper_flank_attack(Pos,Direction,Player,1):- add1_pos(Direction,Pos,NextPiece),nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),           %gets the position of the next piece in that direction
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),player_letter(Player,Piece).                                    %gets the piece and checks if it's player's piece, if it does follows the rule

helper_flank_attack(Pos,Direction,Player,_):- add1_pos(Direction,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                  %gets the position of the next piece in that direction
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),player_letter(OppPlayer,Piece),       %gets the piece and checks if it's an enemy
            helper_flank_attack(NextPiece,Direction,Player,1).                                                                                            %recurse it down

flank_attack(Pos,Direction,Player):-add1_pos(Direction,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                          %gets the position of the next piece in that direction
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),player_piece(OppPlayer,Piece),        %gets the piece and checks if it's an enemy
            helper_flank_attack(NextPiece,Direction,Player,0),                                                                                            %checks if it follows the flank rule
            set_piece(ColumnLetter,Line,' '), format('Player ~w Piece at ~w~w got captured ~n~n',[Player,ColumnLetter,Line]).                                                                                                           % if it does eliminates it

flank_attack(_,_,_).

%phalanx/testudo rule
helper_phalanx_attack(Direction, Direction2, Pos,NextPiece,Player,1):-
                                        add1_pos(Direction2,Pos,NextPieceForPhalanx), nth0(0,NextPieceForPhalanx,ColumnPhalanxLetter), nth0(1,NextPieceForPhalanx,LinePhalanx),         %gets the position of the piece in the perpendicular direction
                                        column_to_number(ColumnPhalanxLetter, ColumnPhalanx),get_piece(ColumnPhalanx,LinePhalanx,Piece),player_letter(Player,Piece),                    %gets the piece and checks if it's a player's piece
                                        add1_pos(Direction,NextPiece,NextPieceForPhalanx2), nth0(0,NextPieceForPhalanx2,ColumnLetter), nth0(1,NextPieceForPhalanx2,Line),               %gets the position of the piece in the direction of the move
                                        column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece2),opposing_player(Player,OppPlayer),player_piece(OppPlayer,Piece2).          %gets the piece and checks if it's an enemy


helper_phalanx_attack(Direction, Direction2, Pos,NextPiece,Player,0):-
                                        add1_pos(Direction2,Pos,NextPieceForPhalanx), nth0(0,NextPieceForPhalanx,ColumnPhalanxLetter), nth0(1,NextPieceForPhalanx,LinePhalanx),         %gets the position of the piece in the perpendicular direction
                                        column_to_number(ColumnPhalanxLetter, ColumnPhalanx),get_piece(ColumnPhalanx,LinePhalanx,Piece),player_letter(Player,Piece),                    %gets the piece and checks if it's a player's piece
                                        add1_pos(Direction,NextPiece,NextPieceForPhalanx2), nth0(0,NextPieceForPhalanx2,ColumnLetter), nth0(1,NextPieceForPhalanx2,Line),               %gets the position of the piece in the direction of the move
                                        column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece2),opposing_player(Player,OppPlayer),player_piece(OppPlayer,Piece2),          %gets the piece and checks if it's an enemy
                                        set_piece(ColumnLetter,Line,' '), format('Player ~w Piece at ~w~w got captured ~n~n',[Player,ColumnLetter,Line]).                                                                                                                %if it is follows the rule

helper_phalanx_attack(Direction, Direction2, Pos,NextPiece,Player,Type):-
                                        add1_pos(Direction2,Pos,NextPieceForPhalanx), nth0(0,NextPieceForPhalanx,ColumnPhalanxLetter), nth0(1,NextPieceForPhalanx,LinePhalanx),         %gets the position of the piece in the perpendicular direction
                                        column_to_number(ColumnPhalanxLetter, ColumnPhalanx),get_piece(ColumnPhalanx,LinePhalanx,Piece),player_letter(Player,Piece),                    %gets the piece and checks if it's a player's piece
                                        add1_pos(Direction,NextPiece,NextPieceForPhalanx2), nth0(0,NextPieceForPhalanx2,ColumnLetter), nth0(1,NextPieceForPhalanx2,Line),               %gets the position of the piece in the direction of the move
                                        column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece2),player_letter(Player,Piece2),                                              %gets the piece and checks if it's a player's piece
                                        helper_phalanx_attack(Direction,Direction2,NextPiece,NextPieceForPhalanx2,Player,Type).                                                              %recurse it down

phalanx_attack(Pos,Direction,Player):-add1_pos(Direction,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),           %gets the position of the next piece in that direction
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),player_letter(Player,Piece),                               %gets the piece and checks if it's an enemy
            directions_90(Direction,X,_), helper_phalanx_attack(Direction,X,Pos,NextPiece,Player,0).                                         %gets a perpendicular direction and checks if it follows the rule

phalanx_attack(Pos,Direction,Player):-add1_pos(Direction,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),           %gets the position of the next piece in that direction
             column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),player_letter(Player,Piece),                              %gets the piece and checks if it's an enemy
             directions_90(Direction,_,X), helper_phalanx_attack(Direction,X,Pos,NextPiece,Player,0).                                        %gets the perpendicular direction and checks if it follows the rule

phalanx_attack(_,_,_).


%push and crush capture
helper_push_and_crush_capture2(Pos,Direction,Player):- add1_pos(Direction,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                         %gets the position of the next piece in that direction
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),(player_letter(OppPlayer,Piece);equal(Piece,' ')).      %gets the piece and checks if it's an enemy or empty space

                                 
helper_push_and_crush_capture(Pos,Direction,Player,0):- add1_pos(Direction,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),      %gets the position of the next piece in that direction
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),player_piece(OppPlayer,Piece),      %gets the piece and checks if it's an enemy
            \+ helper_push_and_crush_capture2(NextPiece,Direction,Player),                                                                            %checks if the next piece is an enemy if it isn't follows the rule              
            set_piece(ColumnLetter,Line,' '), format('Player ~w Piece at ~w~w got captured ~n~n',[Player,ColumnLetter,Line]).                                                                                                          %removes captured piece

helper_push_and_crush_capture(Pos,Direction,Player,1):- add1_pos(Direction,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),      %gets the position of the next piece in that direction
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),player_piece(OppPlayer,Piece),      %gets the piece and checks if it's an enemy
            \+ helper_push_and_crush_capture2(NextPiece,Direction,Player).                                                                            %checks if the next piece is an enemy if it isn't follows the rule              


push_and_crush_capture(Pos,Direction,Player):-add1_pos(Direction,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),             %gets the position of the next piece in that direction
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),player_letter(Player,Piece),                                         %gets the piece and checks if it's an ally
            helper_push_and_crush_capture(NextPiece,Direction,Player,0).                                                                               %checks next position                          

push_and_crush_capture(_,_,_).



%normal capture


%if it is a player's piece follows the rule
check_if_player_piece(NextPiece,Player):- nth0(0,NextPiece,Column), nth0(1,NextPiece,Line), 
            get_piece(Column,Line,Piece),player_letter(Player,Piece).



normal_capture(Pos,Player):- add1_pos(1,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                                         %Gets position of the upper piece
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),player_piece(OppPlayer,Piece),        %checks if it's an enemy
            Y1 is Line+1 , NextPiece2 =[Column,Y1],check_if_player_piece(NextPiece2,Player),                                                            %checks if the position in that direction is a player's piece or a wall
            set_piece(ColumnLetter,Line,' '), format('Player ~w Piece at ~w~w got captured ~n~n',[Player,ColumnLetter,Line]), fail.                                                                                                      %if it is applies the rule, and checks others directions

normal_capture(Pos,Player):-add1_pos(4,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                                          %Gets position of the left piece
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),player_piece(OppPlayer,Piece),        %checks if it's an enemy
            Y1 is Line-1, NextPiece2 =[Column,Y1],check_if_player_piece(NextPiece2,Player),                                                             %checks if the position in that direction is a player's piece or a wall
            set_piece(ColumnLetter,Line,' '), format('Player ~w Piece at ~w~w got captured ~n~n',[Player,ColumnLetter,Line]),fail.                                                                                                      %if it is applies the rule, and checks others directions

normal_capture(Pos,Player):- add1_pos(2,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                                         %Gets position of the right piece
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),player_piece(OppPlayer,Piece),        %checks if it's an enemy
            X1 is Column-1 ,NextPiece2 =[X1,Line],check_if_player_piece(NextPiece2,Player),                                                             %checks if the position in that direction is a player's piece or a wall   
            set_piece(ColumnLetter,Line,' '), format('Player ~w Piece at ~w~w got captured ~n~n',[Player,ColumnLetter,Line]),fail.                                                                                                      %if it is applies the rule, and checks others directions

normal_capture(Pos,Player):- add1_pos(3,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                                         %Gets position of the lower piece
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),opposing_player(Player,OppPlayer),player_piece(OppPlayer,Piece),        %checks if it's an enemy
            X1 is Column+1,NextPiece2 =[X1,Line],check_if_player_piece(NextPiece2,Player),                                                              %checks if the position in that direction is a player's piece or a wall
            set_piece(ColumnLetter,Line,' '), format('Player ~w Piece at ~w~w got captured ~n~n',[Player,ColumnLetter,Line]).                                                                                                           %if it is applies the rule
            

normal_capture(_,_).

%Did the Dux get captured
%checks if the dux has atleast one enemy around him
is_Dux_in_Guerrilla(Player,DuxPos):-add1_pos(1,DuxPos,NextPieceUp), nth0(0,NextPieceUp,ColumnLetterUp), nth0(1,NextPieceUp,LineUp),                           
            column_to_number(ColumnLetterUp, ColumnUp),get_piece(ColumnUp,LineUp,PieceUp),opposing_player(Player,OppPlayer1),player_letter(OppPlayer1,PieceUp);
                                    add1_pos(4,DuxPos,NextPieceDown), nth0(0,NextPieceDown,ColumnLetterDown), nth0(1,NextPieceDown,LineDown),                           
            column_to_number(ColumnLetterDown, ColumnDown),get_piece(ColumnDown,LineDown,PieceDown),opposing_player(Player,OppPlayer4),player_letter(OppPlayer4,PieceDown);
                                    add1_pos(2,DuxPos,NextPieceLeft), nth0(0,NextPieceLeft,ColumnLetterLeft), nth0(1,NextPieceLeft,LineLeft),                           
            column_to_number(ColumnLetterLeft, ColumnLeft),get_piece(ColumnLeft,LineLeft,PieceLeft),opposing_player(Player,OppPlayer2),player_letter(OppPlayer2,PieceLeft);
                                    add1_pos(3,DuxPos,NextPieceRight), nth0(0,NextPieceRight,ColumnLetterRight), nth0(1,NextPieceRight,LineRight),                           
            column_to_number(ColumnLetterRight, ColumnRight),get_piece(ColumnRight,LineRight,PieceRight),opposing_player(Player,OppPlayer3),player_letter(OppPlayer3,PieceRight).
                                    
check_mate_check_piece_or_wall(Player,NextPiece,DuxPos):-            %checks if it's a wall if it is checks if the dux has atleast one enemy around him
            nth0(0,NextPiece,Column), Column>10, is_Dux_in_Guerrilla(Player,DuxPos);
            nth0(0,NextPiece,Column), Column<1, is_Dux_in_Guerrilla(Player,DuxPos);
            nth0(1,NextPiece,Line), Line>8, is_Dux_in_Guerrilla(Player,DuxPos);
            nth0(1,NextPiece,Line), Line<1, is_Dux_in_Guerrilla(Player,DuxPos).


check_mate_check_piece_or_wall(_,NextPiece,_):-nth0(0,NextPiece,Column), nth0(1,NextPiece,Line),                           %checks if it's a piece
            get_piece(Column,Line,Piece),player_letter(_,Piece).
            

 
helper_check_mate(Player,DuxPos):- 
            nth0(0,DuxPos,ColumnLetterUp), nth0(1,DuxPos,LineUp),  column_to_number(ColumnLetterUp, ColumnUp), Y1 is LineUp+1 , NextPieceUp =[ColumnUp,Y1],                     %checks the upper position 
            check_mate_check_piece_or_wall(Player,NextPieceUp,DuxPos),                                                                                                          %and checks if it's a piece or wall
            
            nth0(0,DuxPos,ColumnLetterDown), nth0(1,DuxPos,LineDown),  column_to_number(ColumnLetterDown, ColumnDown), Y2 is LineDown-1 , NextPieceDown =[ColumnDown,Y2],       %checks the bottom position
            check_mate_check_piece_or_wall(Player,NextPieceDown,DuxPos),                                                                                                        %and checks if it's a piece or wall
            
            nth0(0,DuxPos,ColumnLetterLeft), nth0(1,DuxPos,LineLeft),  column_to_number(ColumnLetterLeft, ColumnLeft), X1 is ColumnLeft-1 ,NextPieceLeft =[X1,LineLeft],        %checks the position to the left
            check_mate_check_piece_or_wall(Player,NextPieceLeft,DuxPos),                                                                                                        %and checks if it's a piece or wall
            
            nth0(0,DuxPos,ColumnLetterRight), nth0(1,DuxPos,LineRight),  column_to_number(ColumnLetterRight, ColumnRight), X2 is ColumnRight+1 , NextPieceRight =[X2,LineRight],    %checks the position to the right
            check_mate_check_piece_or_wall(Player,NextPieceRight,DuxPos).                                                                                                           %and checks if it's a piece or wall
                


check_mate(Pos):-add1_pos(1,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                                                                             %checks the upper position 
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),player_dux(Player,Piece),helper_check_mate(Player,NextPiece),set_piece(ColumnLetter,Line,' '),  %and sees if it's a dux
            format('Player ~w Dux at ~w~w got immobilized ~n~n',[Player,ColumnLetter,Line]).
check_mate(Pos):-add1_pos(4,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                                                                             %checks the bottom position
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),player_dux(Player,Piece),helper_check_mate(Player,NextPiece),set_piece(ColumnLetter,Line,' '),  %and sees if it's a dux 
            format('Player ~w Dux at ~w~w got immobilized ~n~n',[Player,ColumnLetter,Line]).                                                                                                                    
check_mate(Pos):-add1_pos(2,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                                                                             %checks the position to the left
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),player_dux(Player,Piece),helper_check_mate(Player,NextPiece),set_piece(ColumnLetter,Line,' '),  %and sees if it's a dux 
            format('Player ~w Dux at ~w~w got immobilized ~n~n',[Player,ColumnLetter,Line]). 
check_mate(Pos):-add1_pos(3,Pos,NextPiece), nth0(0,NextPiece,ColumnLetter), nth0(1,NextPiece,Line),                                                                             %checks the position to the right
            column_to_number(ColumnLetter, Column),get_piece(Column,Line,Piece),player_dux(Player,Piece),helper_check_mate(Player,NextPiece),set_piece(ColumnLetter,Line,' '),  %and sees if it's a dux 
            format('Player ~w Dux at ~w~w got immobilized ~n~n',[Player,ColumnLetter,Line]).   
            
check_mate(_).

/****************************/
/*******GAME OVER Predicates*/
/****************************/
%Checks if the game ended
is_game_over:-board(Board), check_soldiers_and_Dux(Board,0,0,0,0),
            playcounter(X), X>0 , Y is X-1, retract(playcounter(X)), assert(playcounter(Y)), 
            check_possible_moves. %atualiza n?mero de jogadas restantes
is_game_over:-cls, print_board, write('\n The game ended with a draw. \n'), break.


check_possible_moves:-gather_all_moves([[]|ListOfMoves],1), nonvar(ListOfMoves), length(ListOfMoves,X),X>0,
                      gather_all_moves([[]|ListOfMoves2],2), nonvar(ListOfMoves2), length(ListOfMoves2,Y),Y>0.

check_possible_moves:- gather_all_moves([[]|ListOfMoves],1), nonvar(ListOfMoves), length(ListOfMoves,X),X<1,
                       write('\n Player 1 Lost, there is possible move \n'), break.
                       
check_possible_moves:- gather_all_moves([[]|ListOfMoves],2), nonvar(ListOfMoves), length(ListOfMoves,X),X<1,
                       write('\n Player 2 Lost, there is possible move \n'), break.                       
%checks if one of the players lost
check_soldiers_and_Dux(_,1,1,1,1).   % tudo normal continuar normalmente

check_soldiers_and_Dux(T,Pb,PB,Pw,PW):- 
            length(T, 1), Pb=0, cls, print_board, write('\n Player 2 Lost, there is no more soldiers \n'), break;
            length(T, 1), PB=0, cls, print_board, write('\n Player 2 Lost, you lost your Dux \n'), break;
            length(T, 1), Pw=0, cls, print_board, write('\n Player 1 Lost, there is no more soldiers \n'), break;
            length(T, 1), PW=0, cls, print_board, write('\n Player 1 Lost, you lost your Dux \n'), break.

check_soldiers_and_Dux([H|T],Pb,PB,Pw,PW):-check_soldiers_and_Dux_Row(H,Pb,PB,Pw,PW,T). % d?check nas filas 1 a 1 por pe?s

check_soldiers_and_Dux_Row(T,Pb,PB,Pw,PW,X):- length(T, 1),check_soldiers_and_Dux(X,Pb,PB,Pw,PW). % acabou fila atual passa para a pr?ima

check_soldiers_and_Dux_Row([H|T],Pb,PB,Pw,PW,X):-
            H = 'b',check_soldiers_and_Dux_Row(T,1,PB,Pw,PW,X);
            H = 'B',check_soldiers_and_Dux_Row(T,Pb,1,Pw,PW,X);
            H = 'w',check_soldiers_and_Dux_Row(T,Pb,PB,1,PW,X);
            H = 'W',check_soldiers_and_Dux_Row(T,Pb,PB,Pw,1,X);
            H = ' ',check_soldiers_and_Dux_Row(T,Pb,PB,Pw,PW,X).

% Check whether play is valid for a specific player. 
check_if_valid(Move, Player) :- is_own_piece(Move, Player), attempt_to_move(Move).


/*********************************/
/****** MOVE GET AND SET*********/
/*******************************/

move(Move):- nth0(0, Move, ColumnLetter), nth0(1, Move, LinePieceToMove), column_to_number(ColumnLetter, ColumnPieceToMove),
        get_piece(ColumnPieceToMove,LinePieceToMove,Piece),                 %gets the piece on a given position
        nth0(2, Move, ColumnNewPosLetter), nth0(3, Move, LineNewPos),
        set_piece(ColumnNewPosLetter,LineNewPos,Piece),                            %moves it to the new position 
        set_piece(ColumnLetter,LinePieceToMove,' ').   

de_move(Move):-nth0(2, Move, ColumnLetter), nth0(3, Move, LinePieceToMove), column_to_number(ColumnLetter, ColumnPieceToMove),
        get_piece(ColumnPieceToMove,LinePieceToMove,Piece),                 %gets the piece on a given position
        nth0(0, Move, ColumnNewPosLetter), nth0(1, Move, LineNewPos),
        set_piece(ColumnNewPosLetter,LineNewPos,Piece),                            %moves it to the new position 
        set_piece(ColumnLetter,LinePieceToMove,' ').   

% Sees what piece is in position. IMPORTANT NOTE: Column is a number, not a letter. Conversion must be made previously. 
get_piece(Column,Line,Piece):- board(Board), (Column > 0, Column < 11, line_to_position(Line, LineNumber),
                nth1(LineNumber, Board, X), nth1(Column, X, Piece), !).

% If it's not a valid position.
get_piece(_,_,_,Piece):- Piece = 'x'.

% Replaces a character in a given position on the board.
set_piece(ColumnLetter,Line,Piece):- column_to_number(ColumnLetter, Column), line_to_position(Line, LineNumber),                                   
        board(Board), replace(Board,LineNumber,Column,Piece,NewBoard),
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