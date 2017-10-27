/* -*- Mode:Prolog; coding:iso-8859-1; indent-tabs-mode:nil; prolog-indent-width:8; prolog-paren-indent:3; tab-width:8; -*- */

:- reconsult(utils).
:- reconsult(interface).


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
read_move(X):- write('Make your move Player '), write(X), nl, read(MoveString), string_to_move(MoveString, Move), interpret(Move).

read_move(Y):- write('Invalid move! Do a new valid move.\n'), read_move(Y).

/* Takes input and makes a play out of it. */
interpret(X):- write(X).


/* Sees what piece is in position. */
getPeca(Tabuleiro,Coluna,Linha,Peca):- nth1(Coluna, Tabuleiro, X), nth1(Linha, X, Peca).















