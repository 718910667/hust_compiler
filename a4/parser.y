%error-verbose
%locations
%{
#include "stdio.h"
#include "math.h"
#include "string.h"
#include "def.h"
extern int yylineno;
extern char *yytext;
extern FILE *yyin;
void yyerror(const char* fmt, ...);
void display(struct node *,int);
%}

%union {
	long long int val;
	int    type_int;
	float  type_float;
	char   type_char;
	char   type_id[32];
	struct node *ptr;
};


//  %type ������ս��������ֵ����
%type  <ptr> program ExtDefList ExtDef  Specifier ExtDecList FuncDec CompSt VarList VarDec ParamDec Stmt StmList DefList Def DecList Dec Exp Args
//program: ��ʼ�﷨��Ԫ
//ExtDefList: �������ExtDef
//ExtDef: һ��ȫ�ֱ������ṹ������Ķ���
//StructSpecifier: �ṹ��������
//Specifier: ����������
//ExtDecList: �������VarDec
//FuncDec: ����ͷ
//CompSt: �����塢�ɻ�����������������, ���������
//VarList: �β��б�
//VarDec: һ�������Ķ���
//ParamDec: һ���βεĶ���
//Stmt: һ�����
//StmList: ����б�
//DefList: ���������б�
//Def: һ����������
//DecList:
//Dec:
//Exp: һ�����ʽ
//Args: ʵ���б�
//% token �����ս��������ֵ����
%token <type_int> INT              //ָ��INT������ֵ��type_int���дʷ������õ�����ֵ
%token <type_id> ID RELOP TYPE  //ָ��ID,RELOP ������ֵ��type_id���дʷ������õ��ı�ʶ���ַ���
%token <type_float> FLOAT         //ָ��ID������ֵ��type_id���дʷ������õ��ı�ʶ���ַ���
%token <type_char> CHAR
%token LP RP LC RC SEMI COMMA   //��bison�Ը��ļ�����ʱ��������-d�����ɵ�exp.tab.h�и���Щ���ʽ��б��룬����lex.l�а���parser.tab.hʹ����Щ����������
%token PLUS MINUS STAR DIV ASSIGNOP AND OR NOT IF ELSE WHILE RETURN FOR LB RB COMP_PLUS COMP_MINUS PPLUS MMINUS 

%left ASSIGNOP
%left OR
%left AND
%left RELOP
%left PPLUS MMINUS
%left COMP_PLUS COMP_MINUS
%left PLUS MINUS
%left STAR DIV
%right UMINUS UPULS NOT
%right  UPPLUS UMMINUS


%nonassoc LOWER_THEN_ELSE
%nonassoc ELSE

%%



//program: ��ʼ�﷨��Ԫ
program: ExtDefList    {semantic_Analysis0($1);}     ///*��ʾ�﷨��,�������*/
         ; 
		 
//ExtDefList: �������ExtDef
ExtDefList: {$$=NULL;}
          | ExtDef ExtDefList {$$=mknode(EXT_DEF_LIST,$1,$2,NULL,yylineno);}   //ÿһ��EXTDEFLIST�Ľ�㣬���1��������Ӧһ���ⲿ������������
          ;  

//ExtDef: һ��ȫ�ֱ������ṹ������Ķ���
ExtDef:   Specifier ExtDecList SEMI   {$$=mknode(EXT_VAR_DEF,$1,$2,NULL,yylineno);}   //�ý���Ӧһ���ⲿ��������
         |Specifier FuncDec CompSt    {$$=mknode(FUNC_DEF,$1,$2,$3,yylineno);}         //�ý���Ӧһ����������
         | error SEMI   {$$=NULL; }
         ;

//Specifier: ����������
Specifier:TYPE {$$=mknode(TYPE,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);
        if(!strcmp($1,"int")) $$->type=INT;
        if(!strcmp($1,"float")) $$->type=FLOAT;
		if(!strcmp($1,"char[]"))  $$->type=ARRAY_DEF;
		if(!strcmp($1,"char")) $$->type=CHAR;}
		
           ;      
//ExtDecList: �������VarDec
ExtDecList:  VarDec      {$$=$1;}       /*ÿһ��EXT_DECLIST�Ľ�㣬���һ��������Ӧһ��������(ID���͵Ľ��),�ڶ���������Ӧʣ�µ��ⲿ������*/
           | VarDec COMMA ExtDecList {$$=mknode(EXT_DEC_LIST,$1,$3,NULL,yylineno);}
           ; 

//VarDec: һ�������Ķ���
VarDec: ID {$$=mknode(ID,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);}   //ID��㣬��ʶ�����Ŵ���Ž���type_id
		| VarDec LB INT RB {$$=mknode(ARRAY_DEF,$1,NULL,NULL,yylineno);$$->array_size[0]=$3;}//һά����

         ;
FuncDec: ID LP VarList RP   {$$=mknode(FUNC_DEC,$3,NULL,NULL,yylineno);strcpy($$->type_id,$1);}//�����������$$->type_id
		|ID LP  RP   {$$=mknode(FUNC_DEC,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);}//�����������$$->type_id

        ;  
VarList: ParamDec  {$$=mknode(PARAM_LIST,$1,NULL,NULL,yylineno);}
        | ParamDec COMMA  VarList  {$$=mknode(PARAM_LIST,$1,$3,NULL,yylineno);}
        ;
ParamDec: Specifier VarDec         {$$=mknode(PARAM_DEC,$1,$2,NULL,yylineno);}
         ;

CompSt: LC DefList StmList RC    {$$=mknode(COMP_STM,$2,$3,NULL,yylineno);}
       ;
StmList: {$$=NULL; }  
        | Stmt StmList  {$$=mknode(STM_LIST,$1,$2,NULL,yylineno);}
        ;
Stmt:   Exp SEMI    {$$=mknode(EXP_STMT,$1,NULL,NULL,yylineno);}
      | CompSt      {$$=$1;}      //���������ֱ����Ϊ����㣬���������µĽ��
      | RETURN Exp SEMI   {$$=mknode(RETURN,$2,NULL,NULL,yylineno);}
      | IF LP Exp RP Stmt %prec LOWER_THEN_ELSE   {$$=mknode(IF_THEN,$3,$5,NULL,yylineno);}
      | IF LP Exp RP Stmt ELSE Stmt   {$$=mknode(IF_THEN_ELSE,$3,$5,$7,yylineno);}
      | WHILE LP Exp RP Stmt {$$=mknode(WHILE,$3,$5,NULL,yylineno);}
	  | FOR LP Exp SEMI Exp SEMI Exp RP {$$=mknode(FOR,$3,$5,$7,yylineno);}
      ;
  
DefList: {$$=NULL; }
        | Def DefList {$$=mknode(DEF_LIST,$1,$2,NULL,yylineno);}
        ;
Def:    Specifier DecList SEMI {$$=mknode(VAR_DEF,$1,$2,NULL,yylineno);}
        ;
DecList: Dec  {$$=mknode(DEC_LIST,$1,NULL,NULL,yylineno);}
       | Dec COMMA DecList  {$$=mknode(DEC_LIST,$1,$3,NULL,yylineno);}
	   ;
Dec:     VarDec  {$$=$1;}
       | VarDec ASSIGNOP Exp  {$$=mknode(ASSIGNOP,$1,$3,NULL,yylineno);strcpy($$->type_id,"ASSIGNOP");}
       ;
Exp:    Exp ASSIGNOP Exp {$$=mknode(ASSIGNOP,$1,$3,NULL,yylineno);strcpy($$->type_id,"ASSIGNOP");}//$$���type_id����δ�ã����ô�������
      | Exp AND Exp   {$$=mknode(AND,$1,$3,NULL,yylineno);strcpy($$->type_id,"AND");}
      | Exp OR Exp    {$$=mknode(OR,$1,$3,NULL,yylineno);strcpy($$->type_id,"OR");}
      | Exp RELOP Exp {$$=mknode(RELOP,$1,$3,NULL,yylineno);strcpy($$->type_id,$2);}  //�ʷ�������ϵ�����������ֵ������$2��
      | Exp PLUS Exp  {$$=mknode(PLUS,$1,$3,NULL,yylineno);strcpy($$->type_id,"PLUS");}
      | Exp MINUS Exp {$$=mknode(MINUS,$1,$3,NULL,yylineno);strcpy($$->type_id,"MINUS");}
      | Exp STAR Exp  {$$=mknode(STAR,$1,$3,NULL,yylineno);strcpy($$->type_id,"STAR");}
      | Exp DIV Exp   {$$=mknode(DIV,$1,$3,NULL,yylineno);strcpy($$->type_id,"DIV");}
      | LP Exp RP     {$$=$2;}
      | MINUS Exp %prec UMINUS   {$$=mknode(UMINUS,$2,NULL,NULL,yylineno);strcpy($$->type_id,"UMINUS");}
      | NOT Exp       {$$=mknode(NOT,$2,NULL,NULL,yylineno);strcpy($$->type_id,"NOT");}
      | ID LP Args RP {$$=mknode(FUNC_CALL,$3,NULL,NULL,yylineno);strcpy($$->type_id,$1);}
      | ID LP RP      {$$=mknode(FUNC_CALL,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);}
      | ID            {$$=mknode(ID,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);}
      | INT           {$$=mknode(INT,NULL,NULL,NULL,yylineno);$$->type_int=$1;$$->type=INT;}
      | FLOAT         {$$=mknode(FLOAT,NULL,NULL,NULL,yylineno);$$->type_float=$1;$$->type=FLOAT;}
	  | CHAR          {$$=mknode(CHAR,NULL,NULL,NULL,yylineno);$$->type_char=$1;$$->type=CHAR;}
	  | VarDec PPLUS  {$$=mknode(PPLUS,$1,NULL,NULL,yylineno);strcpy($$->type_id,"PPLUS");}
      | VarDec MMINUS {$$=mknode(MMINUS,$1,NULL,NULL,yylineno);strcpy($$->type_id,"MMINUS");}
      | PPLUS VarDec  {$$=mknode(UPPLUS,$2,NULL,NULL,yylineno);strcpy($$->type_id,"UPPLUS");}
      | MMINUS VarDec  {$$=mknode(UMMINUS,$2,NULL,NULL,yylineno);strcpy($$->type_id,"UMMINUS");}
	  | VarDec	ID		{$$=mknode(ID,NULL,NULL,NULL,yylineno);strcpy($$->type_id,"1");}   //ID��㣬��ʶ�����Ŵ���Ž���type_id
	  |VarDec LB INT RB {$$=mknode(ARRAY_DEF,$1,NULL,NULL,yylineno);$$->array_size[0]=$3;}//һά����
      ;
Args:    Exp COMMA Args    {$$=mknode(ARGS,$1,$3,NULL,yylineno);}
       | Exp               {$$=mknode(ARGS,$1,NULL,NULL,yylineno);}
       ;
       
%%

int main(int argc, char *argv[]){
	yyin=fopen(argv[1],"r");
	if (!yyin) return;
	yylineno=1;
	yyparse();
	return 0;
	}

#include<stdarg.h>
void yyerror(const char* fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    fprintf(stderr, "Grammar Error at Line %d Column %d: ", yylloc.first_line,yylloc.first_column);
    vfprintf(stderr, fmt, ap);
    fprintf(stderr, ".\n");
}	
