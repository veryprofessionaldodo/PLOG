code(1, integer_overflow).
code(2, divisao_por_zero).
code(3, id_desconhecido).

traduza_codigo(Codigo, Erro):- code(Codigo,Erro).