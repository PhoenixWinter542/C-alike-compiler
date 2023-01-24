test:
	flex lexer.lex
	gcc lex.yy.c -lfl

