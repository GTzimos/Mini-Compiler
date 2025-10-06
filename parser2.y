%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define YYDEBUG 1

extern FILE *yyin;
extern FILE *yyout;

#define printf(...) fprintf(yyout, __VA_ARGS__)

// Debugging counters
int warning_expr=0;
int expression_index = 1;
int valid_words = 0, invalid_words = 0;
int valid_expr = 0, invalid_expr = 0;

int yylex(void);
int yyerror(const char *s) {
   printf("Σφάλμα σύνταξης στην έκφραση %d\n", expression_index++);
    invalid_expr++;
    return 0;
}

// Υποστήριξη μεταβλητών
#define MAX_VARIABLES 100

typedef struct {
    char name[50];
    int value;
} Variable;

Variable var_table[MAX_VARIABLES];
int var_count = 0;

// Ανάγνωση τιμής μεταβλητής
int get_variable_value(const char* name) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(var_table[i].name, name) == 0)
            return var_table[i].value;
    }

    // Αν δεν υπάρχει, προειδοποίηση και καταγραφή
    printf("WARNING: Η μεταβλητή %s δεν έχει γίνει bind. Χρησιμοποιείται τιμή 0.\n", name);
    warning_expr++;

    
    /*if (var_count < MAX_VARIABLES) {
        strcpy(var_table[var_count].name, name);
        var_table[var_count].value = 0;
        var_count++;
    } */

    return 0;  // default: 0 αν δεν έχει γίνει bind
}

// Εκχώρηση / ενημέρωση μεταβλητής
void set_variable_value(const char* name, int value) {
    for (int i = 0; i < var_count; i++) {
        if (strcmp(var_table[i].name, name) == 0) {
            printf("WARNING: Η μεταβλητή %s έχει ήδη τιμή %d και γίνεται rebind σε %d\n", name, var_table[i].value, value);
            var_table[i].value = value;
            warning_expr++;
            return;
        }
    }
    if (var_count < MAX_VARIABLES) {
        strcpy(var_table[var_count].name, name);
        var_table[var_count].value = value;
        var_count++;
    } else {
       printf("ΠΡΟΕΙΔΟΠΟΙΗΣΗ: Υπέρβαση ορίου μεταβλητών\n");
    }
}

int fatal_errors = 0;

void SyntaxError() {
   printf("Συντακτικό σφάλμα (panic mode), προχωράμε στην επόμενη εντολή.\n");
    fatal_errors++;
}

%}

%union {
    char* str; // Για strings
    int val;   // Για αριθμητικές τιμές
}

// Ορισμός tokens με τύπους
%token <str> INTCONST VARIABLE STRING IDENTIFIER FLOAT INT_EXP
%token <str> BAD_IDENTIFIER BAD_IDENTIFIER_2 UNKNOWN
%token ARROW LPAREN RPAREN
%token DEFFACTS DEFFACT DEFRULE BIND TEST READ PRINTOUT
%token EQUAL PLUS MINUS MUL DIV



// Ορισμός τύπων για κανόνες
%type <str> fact item_list item declaration test_condition 
%type <val> expression operand add_list sub_list mul_list div_list bind_value calculations


%%

// ======= Αρχικός κανόνας του προγράμματος =======
program:
      /* empty */
    | program fact
    | program declaration
    | program expression
    | program calculations
    | program action
    | program test_condition
    | program error {SyntaxError(); yyerrok; yyclearin;}

;



item:
      IDENTIFIER {$$ = $1; } 
    | INTCONST   {$$ = $1; }
    | FLOAT      {$$ = $1; } 
    | INT_EXP    {$$ = $1; }
    | VARIABLE   { $$ = $1; }
    | STRING     {  $$ = $1; }
    | LPAREN STRING RPAREN {
       
        $$ = $2;
    }
;

item_list:
      item
    | item_list item
;



fact:
    LPAREN item_list RPAREN {
       printf("Έγκυρο γεγονός %d\n", expression_index++);
        valid_expr++;
        $$ = NULL;
    }
;

// ======= Επεξεργασία γεγονότων (facts) =======
fact_list:
      fact
    | fact_list fact
;

// ======= Ορίσματα Πράξεων =======
operand:
      INTCONST   { $$ = atoi($1); }
    | VARIABLE   { $$ = get_variable_value($1); }
;


// ======= Τιμή που δίνεται σε bind =======
bind_value:
      INTCONST         { $$ = atoi($1); }
    | calculations       { $$ = $1; }
    | LPAREN READ RPAREN {
        int val;
       printf("Δώσε τιμή: ");
        scanf("%d", &val);
        $$ = val;
    }
;


// ======= Λίστες τελεστέων για πράξεις =======
add_list:
      operand  operand            { $$ = $1 + $2; }
    | add_list operand      { $$ = $1 + $2; }
;

sub_list:
      operand operand       { $$ = $1 - $2; }
    | sub_list operand      { $$ = $1 - $2; }
;

mul_list:
      operand  operand             { $$ = $1 * $2; }
    | mul_list operand      { $$ = $1 * $2; }
;

// ======= Διαχείριση διαίρεσης με υπόλοιπο =======
div_list:
    operand operand {
        if ($2 != 0) {
            int result = $1 / $2;
            int rem = $1 % $2;
            if (rem == 0)
               printf("Αποτέλεσμα διαίρεσης: %d\n", result);
            else
               printf("Αποτέλεσμα διαίρεσης: %d με υπόλοιπο %d\n", result, rem);
            $$ = result;
        } else {
           printf("Σφάλμα: Διαίρεση με το μηδέν!\n");
            $$ = 0;
        }
    }
  | div_list operand {
        if ($2 != 0) {
            int result = $1 / $2;
            int rem = $1 % $2;
            if (rem == 0)
               printf("Ενδιάμεσο αποτέλεσμα: %d\n", result);
            else
               printf("Ενδιάμεσο αποτέλεσμα: %d με υπόλοιπο %d\n", result, rem);
            $$ = result;
        } else {
           printf("Σφάλμα: Διαίρεση με το μηδέν!\n");
            $$ = 0;
        }
    };


calculations:      
    // Αριθμητικές πράξεις
     LPAREN PLUS add_list RPAREN {
       printf("Αποτέλεσμα πρόσθεσης: %d\n", $3);
        $$ = $3;
        valid_expr++;
      }
    | LPAREN MINUS sub_list RPAREN {
       printf("Αποτέλεσμα αφαίρεσης: %d\n", $3);
        $$ = $3;
        valid_expr++;
      }
    | LPAREN MUL mul_list RPAREN {
       printf("Αποτέλεσμα πολλαπλασιασμού: %d\n", $3);
        $$ = $3;
        valid_expr++;
      }
    | LPAREN DIV div_list RPAREN {
        //printf("Αποτέλεσμα διαίρεσης: %d\n", $3);
        $$ = $3;
        valid_expr++;
      }

    |LPAREN BIND VARIABLE bind_value RPAREN {
       printf("Εκχωρήθηκε η μεταβλητή %s με τιμή %d στην έκφραση %d\n", $3, $4, expression_index++);
       set_variable_value($3, $4);
       valid_expr++;
    }  

    // Αριθμητικές πράξεις WARNINGS
     | LPAREN BIND VARIABLE RPAREN {
    printf("WARNING: Η εντολή bind για τη μεταβλητή %s δεν έχει τιμή.\n", $3);
    warning_expr++;
     }
     | LPAREN PLUS operand RPAREN {
       printf("WARNING: Έχεις δώσει 1 operand άρα προσθέτεις με το 0\nΑποτέλεμσα Πρόσθεσης: %d\n", $3);
        $$ = $3;
        warning_expr++;
      }
     | LPAREN MINUS operand RPAREN {
       printf("WARNING: Έχεις δώσει 1 operand άρα αφαιρείς με το 0\nΑποτέλεσμα αφαίρεσης: %d\n", $3);
        $$ = $3;
        warning_expr++;
      }

    | LPAREN MUL operand RPAREN{
        printf("WARNING: Έχεις δώσει 1 operand άρα πολλαπλασιάζεις με το 1\nΑποτέλεσμα πολλαπλασιασμού: %d\n", $3);
        $$ = $3;
        warning_expr++;
    } 

;

expression:
     // Ισότητες με διάφορους συνδυασμούς
      LPAREN EQUAL operand operand RPAREN {
       printf("Έκφραση EQUAL: %d == %d -> %s\n", $3, $4, ($3 == $4) ? "true" : "false");
        $$ = ($3 == $4);
        valid_expr++;
      }

      | LPAREN EQUAL operand calculations RPAREN {
       printf("Έκφραση EQUAL: %d == %d -> %s\n", $3, $4, ($3 == $4) ? "true" : "false");
        $$ = ($3 == $4);
        valid_expr++;
      }
      | LPAREN EQUAL calculations operand RPAREN {
       printf("Έκφραση EQUAL: %d == %d -> %s\n", $3, $4, ($3 == $4) ? "true" : "false");
        $$ = ($3 == $4);
        valid_expr++;
      }
      | LPAREN EQUAL calculations calculations RPAREN {
       printf("Έκφραση EQUAL: %d == %d -> %s\n", $3, $4, ($3 == $4) ? "true" : "false");
        $$ = ($3 == $4);
        valid_expr++;
      }
;
   
// ======= test συνθήκη για σύγκριση =======
test_condition:
    //test χωρις =
    LPAREN TEST LPAREN INTCONST INTCONST RPAREN RPAREN {
        printf("WARNING: Λείπει τελεστής σύγκρισης (π.χ. =) στη συνθήκη test: test (%s %s)\n", $4, $5);
        warning_expr++;
    }
    | LPAREN TEST expression RPAREN {
       printf("Έγκυρη έκφραση test %d (αποτέλεσμα: %d)\n", expression_index++, $3);
        valid_expr++;
    }
;


// ======= Ενέργειες  printout =======
action:
    LPAREN PRINTOUT RPAREN {
      printf("WARNING: Κενή εντολή printout χωρίς identifier ή τιμές.\n");
      warning_expr++;
    }
    | LPAREN PRINTOUT IDENTIFIER RPAREN {
      printf("WARNING: Εντολή printout χωρίς περιεχόμενο για εκτύπωση.\n");
      warning_expr++;
    }
    
    
    | LPAREN PRINTOUT IDENTIFIER LPAREN STRING RPAREN RPAREN {
       printf("%s\n", $5);
        valid_expr++;
    }

    | LPAREN PRINTOUT LPAREN STRING RPAREN RPAREN{
        printf("WARNING: Δεν υπάρχει identifier μετά το printout \n");
        printf("%s\n", $4);
        warning_expr++;
    }
;


// ======= Λίστα ενεργειών defrule (π.χ. bind, printout) =======
action_list:
      action
    | action_list action
;


// ======= Δηλώσεις deffacts/defrule =======
declaration:
      LPAREN DEFFACTS IDENTIFIER fact_list RPAREN {
       printf("Έγκυρη δήλωση deffacts (%s), έκφραση %d\n", $3, expression_index++);
        valid_expr++;
    }

    | LPAREN DEFRULE IDENTIFIER fact_list test_condition ARROW action_list RPAREN {
       printf("Έγκυρη δήλωση defrule (%s), έκφραση %d\n", $3, expression_index++);
        valid_expr++;
    }


     // 1. Κενός κανόνας
    | LPAREN DEFRULE IDENTIFIER RPAREN {
        printf("WARNING: Κενός κανόνας defrule (χωρίς patterns ή actions).\n");
        
        warning_expr++;
    }

    // 2. Λείπει ARROW (->)
    | LPAREN DEFRULE IDENTIFIER fact_list test_condition action_list RPAREN {
        printf("WARNING: Λείπει \"->\" (ARROW) στο defrule. Ξεκίνησε απευθείας με action χωρίς σύμβολο μετάβασης.\n");
        warning_expr++;
        
    }

    //3. Λειπουν τα facts
    | LPAREN DEFRULE IDENTIFIER ARROW action_list RPAREN {
    printf("WARNING: Ο κανόνας defrule \"%s\" δεν έχει καθόλου συνθήκες πριν το \"->\"\n", $3);
    //printf("@@@@ DEFRULE ΧΩΡΙΣ ΣΥΝΘΗΚΕΣ @@@@\n");
    warning_expr++;
}
   
;


%%



// ======= Συνάρτηση main =======
int main(int argc, char* argv[]) {
    // Προεπιλογές
yyin = stdin;
yyout = stdout;

    // Αν δοθούν ορίσματα, άνοιγμα αρχείων
    if (argc >= 2) {
        FILE *input_file = fopen(argv[1], "r");
        if (!input_file) {
            perror("Σφάλμα στο άνοιγμα του αρχείου εισόδου");
            return 1;
        }
        yyin = input_file;
    }

    if (argc >= 3) {
        FILE *output_file = fopen(argv[2], "w");
        if (!output_file) {
            perror("Σφάλμα στο άνοιγμα του αρχείου εξόδου");
            return 1;
        }
        yyout = output_file;
    }

    // Εκκίνηση parser
    yydebug = 0;
    int result = yyparse();

    // Τελικά στατιστικά
    fprintf(yyout,"\n=== RUNNING PARSER BUILD ===\n");
    fprintf(yyout,"ΣΩΣΤΕΣ ΛΕΞΕΙΣ: %d\n", valid_words);
    fprintf(yyout,"ΣΩΣΤΕΣ ΕΚΦΡΑΣΕΙΣ: %d\n", valid_expr);
    fprintf(yyout,"ΛΑΘΟΣ ΛΕΞΕΙΣ: %d\n", invalid_words);
    fprintf(yyout,"ΛΑΘΟΣ ΕΚΦΡΑΣΕΙΣ: %d\n", invalid_expr);
    fprintf(yyout,"ΛΑΘΗ ΣΥΝΤΑΞΗΣ (panic mode): %d\n", fatal_errors);
    fprintf(yyout,"PARSER WARNINGS: %d\n", warning_expr);

    // Κλείσιμο αρχείων
    if (yyin != stdin) fclose(yyin);
    if (yyout != stdout) fclose(yyout);

    return result;
}
