/* -*- Mode:Prolog; coding:iso-8859-1; indent-tabs-mode:nil; prolog-indent-width:8; prolog-paren-indent:3; tab-width:8; -*- */

/* INTERFACE */
:- dynamic(board/1).

board( [
	   ['w','w','w','w','w','w','w','w','w','w','8'],
	   [' ',' ',' ',' ','W',' ',' ',' ',' ',' ','7'],
	   [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','6'],
	   [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','5'],
	   [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','4'],
	   [' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','3'],
	   [' ',' ',' ',' ',' ','B',' ',' ',' ',' ','2'],
	   ['b','b','b','b','b','b','b','b','b','b','1'],
	   ['a','b','c','d','e','f','g','h','i','j']

	   ]).


/* If line reached the end, stop, and print a new line. */
print_line([]) :- print_newline.

/* If line has content, continue reading until the end. */
print_line( [Head|Tail]) :- print_character(Head), print_line(Tail).

/* If board has reached the end, print the final separating line. */
print_board([]) :- print_top.

/* While board has content, continue to print lines. */
print_board([Head|Tail]) :- print_top, print_line(Head), print_board(Tail).

print_board :- board(X), print_board(X).

/* Tutorial for movement */
print_make_move:- write('Write your move like "b3-b7.", b3 being the piece position and b7 the piece destination.').

/* Print specific character. */
print_character(X) :- write('|  '), write(X), write('  ').

/* Print separating line. */
print_top :- write('-------------------------------------------------------------\n').

/* Print on a new line. */
print_newline :- write('\n').

