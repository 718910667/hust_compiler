flex:lex.l
	flex lex.l
bison:parser.y
	bison -d parser.y
all:lex.l parser.y
	flex lex.l
	bison -d parser.y
result:lex.l parser.y ast.c
	flex lex.l
	bison -d parser.y
	gcc lex.yy.c parser.tab.c ast.c -o a.exe
	a.exe test.c
out:lex.yy.c parser.tab.c ast.c
	gcc lex.yy.c parser.tab.c ast.c -o a.exe
	a.exe test.c
output:test.c
	a.exe test.c
clean:lex.yy.c parser.tab.c parser.tab.h
	del lex.yy.c parser.tab.c parser.tab.h
conflict:parser.y
	bison -d -v parser.y