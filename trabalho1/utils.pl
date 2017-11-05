% Utilities 
:- dynamic(playcounter/1).

is_row(Number) :- Number > 0, Number < 9.
isColumn(Letter) :- member(Letter, "abcdefghjABCDEFGHJ").

equal(A,A).

% All valid player letters. 
player_letter(1,'w').
player_letter(1,'W').
player_letter(2,'b').
player_letter(2,'B').

% Converts Column Letter to Number 
column_to_number('a',1).
column_to_number('A',1).
column_to_number('b',2).
column_to_number('B',2).
column_to_number('c',3).
column_to_number('C',3).
column_to_number('d',4).
column_to_number('D',4).
column_to_number('e',5).
column_to_number('E',5).
column_to_number('f',6).
column_to_number('F',6).
column_to_number('g',7).
column_to_number('G',7).
column_to_number('h',8).
column_to_number('H',8).
column_to_number('i',9).
column_to_number('I',9).
column_to_number('j',10).
column_to_number('J',10).

% Split Array into Args 
string_to_move(StringA-StringB, ListOfMove):-
	name(StringA, [ColumnASCII1,RowASCII1]), name(StringB,[ColumnASCII2,RowASCII2]), isColumn(ColumnASCII1), isColumn(ColumnASCII2), name(Row1, [RowASCII1]), name(Row2, [RowASCII2]), 
	name(Column1, [ColumnASCII1]), name(Column2, [ColumnASCII2]), is_row(Row1), is_row(Row2),
	ListOfMove = [Column1,Row1,Column2,Row2].


% Line Number to position in Board array. 
line_to_position(1,8).
line_to_position(2,7).
line_to_position(3,6).
line_to_position(4,5).
line_to_position(5,4).
line_to_position(6,3).
line_to_position(7,2).
line_to_position(8,1).

