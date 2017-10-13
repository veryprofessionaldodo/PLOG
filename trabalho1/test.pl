/* -*- Mode:Prolog; coding:iso-8859-1; indent-tabs-mode:nil; prolog-indent-width:8; prolog-paren-indent:3; tab-width:8; -*- */

print_board :- print_line, print_line, print_line,print_line, print_line, print_line,print_line, print_line, print_top.
print_line :- print_top , print_edge, print_character, print_edge,print_character, print_edge,print_character, print_edge,print_character, print_edge,print_character, print_edge,print_character, print_edge,print_character, print_edge,print_character, print_edge,print_character, print_edge,print_character, print_edge,  print_newline.
print_top :- write('-------------------------------------------------------------\n').

print_edge:- write('|').

print_newline :- write('\n').

print_character :- write('  '), write('W'), write('  ').