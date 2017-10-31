/* -*- Mode:Prolog; coding:iso-8859-1; indent-tabs-mode:nil; prolog-indent-width:8; prolog-paren-indent:3; tab-width:8; -*- */

:- reconsult(utils).
:- reconsult(interface).
:- use_module(library(lists)).


/* BEGINNING OF GAME */



latrunculli:- write('Which type of game do you want to play? \n 1 - Player Versus Player \n 2 - Player Versus AI \n 3 - AI Versus AI\n'),
            read(ReadMode), playMode(ReadMode).

/* Starts a new game in pvp. */
playMode(1) :-  board(StartBoard), print_board, nl, write('Good luck to both!\n'), print_make_move, nl, play(StartBoard, 1), nl.

/* Starts a new game in pvAI. */
playMode(2) :-  board(StartBoard), print_board, nl, write('Good luck!\n'), print_make_move, nl, play(StartBoard, 2), nl.

/* Starts a new game in AIvAI. */
playMode(3) :-  board(StartBoard), print_board, nl, write('Watch it all unfold before you!\n'), print_make_move, nl, play(StartBoard, 3), nl.

/* Invalid game mode. */
playMode(X) :-  write('Invalid game type! Try again. \n 1 - Player Versus Player \n 2 - Player Versus AI \n 3 - AI Versus AI'),
			read(ReadMode), playMode(ReadMode).



/* THE GAME LOOP */


/* Game Loop, in pvp. */
play(Board, 1) :- read_move(1), print_board, read_move(2), print_board, play(Board, 1).

/* Game Loop in pvAI. */
play(Board, 2) :- print_board.

/* Game Loop in AIvAI. */
play(Board, 3) :- print_board.

/* Reads move for a player passed in argument. */
read_move(X):- write('Make your move Player '), write(X), nl, read(MoveString), string_to_move(MoveString, Move), check_if_valid(Move, X),
	interpret(Move).

read_move(Y):- write('Invalid move! Do a new valid move.\n'), read_move(Y).

/* Check whether play is valid for a specific player. */ 
check_if_valid(Move, Player) :- is_own_piece(Move, Player).

/* Checks if player is moving is own piece, not an enemy's or a blank space. */
is_own_piece(Move, Player) :- nth0(0, Move, Column), nth0(1, Move, Line), board(Board), 
        get_piece(Board, Column, Line, Piece),  player_letter(Player, Piece).

/* Takes input and makes a play out of it. */
interpret(X):- write(X).

/* Sees what piece is in position. */
get_piece(Board,ColumnLetter,Line,Piece):- column_to_number(ColumnLetter, ColumnNumber), line_to_position(Line, LineNumber),
     nth1(LineNumber, Board, X), nth0(ColumnNumber, X, Piece), write(Piece).














