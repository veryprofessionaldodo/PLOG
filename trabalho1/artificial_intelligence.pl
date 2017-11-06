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

AILevel(1).
AILevel(2).
AILevel(3).

% Gather all moves for all pieces.
gather_all_moves(AIDifficulty, ListOfMoves) :- AILevel(AIDifficulty), write('\nThinking...\n'), board(Board), gather_moves_recursive(Board, ListOfMoves, 0).

% End of recursion.
gather_moves_recursive([], ListOfMoves, RowNumber).

% Recursive function that calls itself to see all the pieces.
gather_moves_recursive([Row|Tail], ListOfMoves, RowNumber) :- gather_moves_by_row(Row, ListOfMoves, RowNumber, 0), NewRow is RowNumber + 1, gather_moves_recursive(Tail, ListOfMoves, NewRow).

% Has reached the ending row.
gather_moves_by_row([], ListOfMoves, RowNumber, ColumnNumber).

% Gather all pieces in a Row.
gather_moves_by_row([Piece|Tail], ListOfMoves, RowNumber, ColumnNumber) :- gather_moves_piece(Piece, RowNumber, ColumnNumber, ListOfMoves), NewColumn is ColumnNumber + 1, 
			gather_moves_by_row(Tail, ListOfMoves, RowNumber, NewColumn). 

% Gather all moves in a specific place.			
gather_moves_piece(Piece, RowNumber, ColumnNumber, ListOfMoves).

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
		Médio - Vê a posição de 70% das peças, e não capturar nem por Testudp nem por Falange.
		Fácil - Vê a posição de 50% das peças, não sabe flanquear, atacar por Testudo, nem Falange. Não sabe defender bem próprio Dux (não põe nenhuma peça no meio, tenta só mexer o Dux).
*/
