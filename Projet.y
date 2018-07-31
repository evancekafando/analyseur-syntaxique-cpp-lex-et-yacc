%token NOMBRE IDENT        /* On met les "tokens" (unités lexicales)     */
%token '(' ')'             /* dans l'ordre ou ils apparaissent           */
%token '+' '-' '*' '/'  /* dans le fichier lex (fortement recommandée) */
%token '\n'

%start liste_expr
%left '+' '-'      /* Associativité de gauche à droite */
%left '*' '/'      /* Associativité de gauche à droite */
                   /* et priorité par rapport à '+'    */

%{

#include <iostream>
#include <stdio.h>
#include <cstdlib>
#include <string>
#include <vector>
#include <string>
#include <sstream>
#include <cctype>

using namespace std;
	
class NoeudBin
{ 
	// noeud pour un Arbre binaire
	public:
		string element ;                         // valeur du noeud
	        NoeudBin *gauche;                        // Pointeur vers le fils gauche
	        NoeudBin *droit;                        // Pointeur vers le fils droit
	        char Type;                              //Type d'operateur qui est specifié par la valeur "element" du noeud rencontré ("NoeudBin")	
						

        // deux constructeurs avec et sans valeur initiale
	NoeudBin (){
        gauche = droit = NULL ;
        }
        NoeudBin(string elem,NoeudBin *g, NoeudBin *d, char c ) {
        element = elem ;
        gauche = g ;
        droit = d ;
	Type = c;
        }
	
        NoeudBin *FilsGauche () {
        return gauche ;
        }
	
         NoeudBin *FilsDroit () {
	return droit ;
        }
	
       string Valeur () const{
       return element ;
       }
       
       void FixerValeur ( string val )
       {
          element = val ;
       }
       
       bool EstUneFeuille () const                                    //retourne vrai si le noeud en question est une feuille
      {
       return ( gauche == NULL ) && ( droit == NULL ) ;
      }
};


void Afficher();

void AffichagePostfixe(NoeudBin* , int );

 

//Simplification simple ie.   x 2- x 6 2 / + -> ((x - 2) * (x + (6 / 2))) 
//Parcour Infixe qui retourne une expression developpée.
//La valeur du type qui specifie si element = operateur, ce qui servira de comparaison plus tard pour simplifier si possible encore l'expression.
string Infixe( NoeudBin* r)
{
	//Si la r n'est pas nulle on fait un parcour Infixe Gauche r Droit
	if( r )
	{

		//Si c'est une feuille on recupere son contenue
		if(r->FilsGauche() == NULL && r->FilsDroit() == NULL)
		{
			return r->element;
		}
		else
		{ 
			string Temp1, Temp2, Expression;
			Temp1 = Infixe( r->FilsGauche() );
			Temp2 = Infixe( r->FilsDroit() );
			Expression = '(' + Temp1 + ' ' + r->element + ' ' + Temp2 + ')';
			return Expression;
		}
	}
	
	//Sinon on retourne une chaine de caractere vide
	string vide = "";
	return vide;
}

//Parcour Infixe simplifiée. ie. x 2- x 6 2 / + -> ((x - 2) * (x + (6 / 2))) -> (x - 2)*(x + 3)	
//On retourne une expression simplifiee.
string InfixeSimplifier( NoeudBin* r);



//Fonction qui convertis un float de base en string
string to_string(float );

//Fonction qui convertis un string en float
float to_float(string );


//Yacc
#define YYSTYPE NoeudBin* /* Le type des $$ $1 $2 etc. */

/* Pour raisons de compilation : */

extern FILE *yyin;
extern char yytext[];
extern "C" int yylex();
int yyparse();
extern int yyerror(string);

/* Variable globale pour compter les expressions */
int nb_expr=0;
/* Variable globale pour garder la r de chaque Arbre */
vector<NoeudBin*> Arbre;
%}

%% 

					
//Analyse de plusieurs expressions
liste_expr : liste_expr expr '\n' {
		Arbre.push_back($2);
		nb_expr++;  
	}
	| { /* cas de terminaison (mot vide) */ }
	;

expr    : NOMBRE	{ $$ = new NoeudBin(yytext, NULL, NULL, 'n'); } //Un nombre
	| IDENT		{ $$ = new NoeudBin(yytext, NULL, NULL, 'i'); } //Une variable

	//Cas des opérateurs
	| expr expr '+'	{ $$ = new NoeudBin("+", $1, $2, 'o'); }
	| expr expr '-'	{ $$ = new NoeudBin("-", $1, $2, 'o');}
	| expr expr '*'	{ $$ = new NoeudBin("*", $1, $2, 'o');  }
	| expr expr '/'	{ $$ = new NoeudBin("/", $1, $2, 'o'); }
	;
%% 

int main(int argc,char **argv)
{
  	++argv,--argc;
  	if (argc>0) yyin=fopen(argv[0],"r"); else yyin=stdin; 
        
  	yyparse(); /* ANALYSE GRAMMATICALE (ou SYNTAXIQUE) */
	Afficher();
  	cout << nb_expr << " expressions ont détectées \n";

  	return 0;
}

int yyerror(string msg) { cerr << msg << endl; return 0;}

/* Affichage visuel d'un Arbre binaire en mode postefixe simple */
void AffichagePostfixe(NoeudBin* r, int Niveau)
{
  int i=0;
  if (r)
  { AffichagePostfixe(r->FilsDroit(), Niveau+2);
    for(i = 0; i < Niveau; i++) cout << ' '; cout << r->Valeur() << '\n';
    AffichagePostfixe(r->FilsGauche(), Niveau+2);
  }
} /* afficher() */
void Afficher()
{
	//Parcours de l'Arbre
	for(int i = 0; i < Arbre.size(); ++i)
	{
		string itmp1 = Infixe( Arbre[i] );
		string itmp2 = InfixeSimplifier( Arbre[i] );
		cout <<"Affichage Postfixe Simple "<<endl;
		AffichagePostfixe(Arbre[i], 0);
		cout << "Expression Infixe "<<i+1<<" : "<< itmp1 << endl;
		cout << "Infixe simplifier "<<i+1<<" : "<< itmp2 << endl << endl;
	}
}
/*Specifications des fonctions du programme déclarées plus haut*/
string to_string(float a)
{
	//Utilisation d'un stringstream pour la conversion
	ostringstream ss;
	ss << a;
	return ss.str();
}


float to_float(string a)
{
	//Utilisation d'un stringstream qui convertis automatiquement
	stringstream ss;
	float v;
	ss << a;
	ss >> v;
	return v;
}

string InfixeSimplifier( NoeudBin* r)
{
	//Si la r n'est pas nulle on fait un parcour Infixe Gauche r Droit
	if( r )
	{

		//Si c'est une feuille on recupere son contenue
		if(r->FilsGauche() == NULL && r->FilsDroit() == NULL)
		{
			return r->element;
		}
		else
		{ 
			string Temp1, Temp2, Expression;
			Temp1 = InfixeSimplifier( r->FilsGauche());
			Temp2 = InfixeSimplifier( r->FilsDroit());
			if ((r->FilsGauche()->Type == 'n') && (r->FilsDroit()->Type == 'n'))
			{
				if(r->Valeur() == "*")
				{      r->Type='n';
					return to_string(to_float(Temp1) * to_float(Temp2));}
				else if(r->Valeur() == "+")
				{      r->Type='n';
					return to_string(to_float(Temp1)  + to_float(Temp2));}
				else if(r->Valeur() == "-")
				{	r->Type='n';
					return to_string(to_float(Temp1) - to_float(Temp2));}
				else if(r->Valeur() == "/")
				{	r->Type='n';
					return to_string(to_float(Temp1) / to_float(Temp2));}
			}
			
			
			else if ((r->FilsGauche()->Type == 'n') && (r->FilsDroit()->Type == 'i'))
			{
				if(r->Valeur() == "*")
				{     //r->Type='n';
					return  Temp1 + Temp2 ;
				}
			}
			
			else if ((r->FilsGauche()->Type == 'i') && (r->FilsDroit()->Type == 'n'))
			{
				if(r->Valeur() == "*")
				{     //r->Type='n';
					return  Temp2 + Temp1 ;
				}
			}
			
			else if ((r->FilsGauche()->Type == 'i') && (r->FilsDroit()->Type == 'i'))
			{
				if(r->Valeur() == "*")
				{     //r->Type='n';
					return Temp1 +  Temp2 ;
				}
			}
			
			Expression = '(' + Temp1 + ' ' + r->element + ' ' + Temp2 + ')';
			return Expression;
			
		}
	}
	
	//Sinon on retourne une chaine de caractere vide
	string vide = "";
	return vide;

}

