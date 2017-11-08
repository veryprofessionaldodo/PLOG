/************************/
/***** AI BEHAVIOUR *****/
/************************/

% Points in each AI Move:
% 10 - Direct attack to Dux
% 9 - Defends own Dux
% 7 - Positioning move to Dux
% 6 - Capture by Testudo, Flank or Phalanx
% 5 - Positioning move to Testudo, Flank or Phalanx
% 2 - Capture enemy pawn
% 1 - Position to enemy pawn
% 0 - No available move that attack enemy, random move selected.

% Gather all moves for all pieces.
gather_all_moves([ListOfMoves|FinalList], Player) :- write('\nThinking...\n'), board(Board), gather_moves_recursive(Board, ListOfMoves, 8, Player), write(ListOfMoves), FinalList is ListOfMoves.

% End of recursion.
gather_moves_recursive([], ListOfMoves, RowNumber, Player).

% Recursive function that calls itself to see all the pieces.
gather_moves_recursive([Row|Tail], ListOfMoves, RowNumber, Player) :- gather_moves_by_row(Row, ListOfMoves, RowNumber, 0, Player), NewRow is RowNumber - 1, gather_moves_recursive(Tail, ListOfMoves, NewRow).

% Has reached the ending row.
gather_moves_by_row([], ListOfMoves, RowNumber, ColumnNumber, Player).

% Gather all pieces in a Row.
gather_moves_by_row([Piece|Tail], ListOfMoves, RowNumber, ColumnNumber, Player) :- (player_letter(Player, Piece), write('\nPeça.'),gather_moves_piece(Piece, RowNumber, ColumnNumber, ListOfMoves)) ; NewColumn is ColumnNumber + 1, 
			gather_moves_by_row(Tail, ListOfMoves, RowNumber, NewColumn). 

% Gather all moves in a specific place.			
gather_moves_piece(Piece, RowNumber, ColumnNumber, ListOfMoves) :-
		write('Left\n'),NewColumn1 is ColumnNumber - 1, gather_moves_left(ListOfMoves, ColumnNumber, RowNumber, NewColumn1, RowNumber), write(ListOfMoves),
		write('Right\n'),NewColumn2 is ColumnNumber + 1, gather_moves_right(ListOfMoves, ColumnNumber, RowNumber, NewColumn2, RowNumber), write(ListOfMoves),
		write('Down\n'),NewRow1 is RowNumber - 1, gather_moves_down(ListOfMoves, ColumnNumber, RowNumber, ColumnNumber, NewRow1), write(ListOfMoves),
		write('Up\n'),NewRow2 is RowNumber + 1, gather_moves_up(ListOfMoves, ColumnNumber, RowNumber, ColumnNumber, NewRow2), write(ListOfMoves).

gather_moves_left(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber) :-  NewColumn1 is ColumnNumber - 1, NewColumn1 > 0, get_piece(NewColumn1, RowNumber, Piece), Piece = ' ',
		NewMove is [OriginalColumn, OriginalRow, NewColumn1, RowNumber], NewList is [NewMove|ListOfMoves], gather_moves_left(NewList, OriginalColumn, OriginalRow, NewColumn1, RowNumber).

% Has reached the end of column, or hit another piece.
gather_moves_left(ListOfMoves, OriginalRow, OriginalColumn, ColumnNumber, RowNumber). 

gather_moves_right(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber) :-NewColumn1 is ColumnNumber + 1, NewColumn1 < 11, get_piece(NewColumn1, RowNumber, Piece), Piece = ' ',
		NewMove is [OriginalColumn, OriginalRow, NewColumn1, RowNumber], NewList is [NewMove|ListOfMoves], gather_moves_right(NewList, OriginalColumn, OriginalRow, NewColumn1, RowNumber).

% Has reached the end of column, or hit another piece.
gather_moves_right(ListOfMoves, OriginalRow, OriginalColumn, ColumnNumber, RowNumber). 

gather_moves_up(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber) :-NewRow1 is RowNumber + 1, NewRow1 < 9, get_piece(ColumnNumber, NewRow1, Piece), Piece = ' ',
		NewMove is [OriginalColumn, OriginalRow, ColumnNumber, NewRow1], NewList is [NewMove|ListOfMoves], gather_moves_up(NewList, OriginalColumn, OriginalRow, ColumnNumber, NewRow1).

% Has reached the end of row, or hit another piece.
gather_moves_up(ListOfMoves, OriginalRow, OriginalColumn, ColumnNumber, RowNumber). 

gather_moves_down(ListOfMoves, OriginalColumn, OriginalRow, ColumnNumber, RowNumber) :- NewRow1 is RowNumber - 1, NewRow1 > 0, get_piece(ColumnNumber, NewRow1, Piece), Piece = ' ',
		NewMove is [OriginalColumn, OriginalRow, ColumnNumber, NewRow1], NewList is [NewMove|ListOfMoves], gather_moves_down(NewList, OriginalColumn, OriginalRow, ColumnNumber, NewRow1).

% Has reached the end of row, or hit another piece.
gather_moves_down(ListOfMoves, OriginalRow, OriginalColumn, ColumnNumber, RowNumber). 

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
