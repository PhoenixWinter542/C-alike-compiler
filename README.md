# CS152 Project
 
Language Name:  Pilot<br>
File extention: .plt<br>
Compiler Name:  Compilotron <br>

| **Language Feature**               	| **Code Example**                                                   	|
|------------------------------------	|--------------------------------------------------------------------	|
| Integer scalar variables           	| int x; int y;<br>int test, int test1;                              	|
| One-dimensional arrays of integers 	| int[100] name1; name1[1] = 10;                                     	|
| Assignment Statements              	| x = 10; int x = 10; int x = a;                                     	|
| Arithmetic operators               	| a+b   a-b   a*b   a/b                                              	|
| Relational operators               	| a>b   a<b   a==b   a!=b                                            	|
| While and Do-While loops           	| while(_condition_){_code_}<br><br>do{_code_}while(_condition_)     	|
| If-then-Else statements            	| if(_condition_){_code_}else{_code_}<br><br>if(_condition_){_code_} 	|
| Read and Write statements          	| read x           <br><br>write "Print to console"                  	|
| Comments                           	| //_Comment after_                                                  	|
| Functions                          	| int func(_arguments_){_code_}                                      	|

| ** Symbol in Language**             | **Token Name**                                                      |
|------------------------------------	|--------------------------------------------------------------------	|
| int                                 | INTEGER                                                             |
| [                                   | L_BRACK                                                             |
| ]                                   | R_BRACK                                                             |
| =                                   | ASSIGN                                                              | 
| ==                                  | EQUAL                                                               |
| <=                                  | LTE                                                                 |
| >=                                  | GTE                                                                 |
| !=                                  | NOTEQUAL                                                            |
| +                                   | ADD                                                                 |
| -                                   | SUBTRACT                                                            |
| *                                   | MULTIPLY                                                            |
| /                                   | DIVIDE                                                              |
| %                                   | MOD                                                                 |
| while                               | WHILE                                                               |
| (                                   | L_PARENTH                                                           |
| )                                   | R_PARENTH                                                           |
| if                                  | IF                                                                  |
| else                                | ELSE                                                                |
| read                                | READ                                                                |
| write                               | WRITE                                                               |
| ;                                   | END                                                                 |
| {                                   | L_BRACE                                                             |
| }                                   | R_BRACE                                                             |
| ,                                   | SEPARATOR                                                           |

# Miscellaneous

* Valid identifiers:
    * Variable names must start with a digit and cannot end with an underscore.
    * Variable names cannot be a keyword e.g. "if", "int".
    * Variable names cannot include special characters e.g. '"[({,.
    * Valid variable names include: var, test1, longer_variable1_name43
* Case sensitive:         yes <br>
* Whitespaces ignored:    yes <br>
