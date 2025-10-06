# README

## Group Project: Lexical & Syntax Analyzer for CLIPS/Lisp-like Language

### Project & Group Information
This project was developed as a group assignment to fulfill the laboratory requirements for the Compilers course.

- **Course:** Compilers
- **Context:** Group Project for Course Requirements  
- **Participants:** A team of 4 people  

### Overview and Functionality
The project implements a Lexical Analyzer (Lexer) and a Syntax Analyzer (Parser) using the Flex and Bison tools, respectively. The target language features a structure heavily reliant on S-expressions, similar to CLIPS or Lisp.

#### 1. Lexical Analyzer (Lexer - all_tokens2.l)
The Lexer is responsible for tokenizing the input file, correctly identifying the following elements:

- **Keywords:** deffacts, defrule, bind, test, read, and printout.  
- **Constants:** Integers (INTCONST), Floats (FLOAT_RE), and Scientific Notation Integers (INT_EXP_RE).  
- **Variables:** Identified by the prefix ? (e.g., ?var).  
- **Operators & Delimiters:** Arithmetic operators (+, -, *, /), Equality (=), the rule separator (->), parentheses ((, )).  
- **Comments:** Comments starting with ; are ignored by the parser.  

#### 2. Syntax Analyzer (Parser - parser2.y)
The Parser enforces the grammar rules and performs basic semantic actions:

- **Declarations:** Supports valid fact expressions, and the top-level declarations deffacts and defrule.  
- **Arithmetic Operations:** Handles standard operations (+, -, *, /) with multiple operands.  
- **Division:** Implements checks for division by zero and calculates the remainder for integer division.  
- **Variable Binding:** The bind command allows assigning integer values or the result of calculations to variables.  
- **Variable Scope:** The parser includes logic to retrieve variable values and issues a warning if a variable is used before it is bound (defaulting to 0). It also warns on a rebind of an already assigned variable.  
- **Equality and Testing:** Supports equality comparisons (=) between constants and/or calculation results. The test condition is used within rules to evaluate these expressions.  
- **I/O:** Implements the printout action for printing strings and the read function to accept user input during execution (for bind).  
- **Error Handling:** The parser implements panic mode recovery for syntax errors, continuing to the next statement after encountering an error. Warnings are issued for common issues like missing operators in test, rules with no conditions, or missing content in printout.  

### Build and Run Instructions
The project uses a standard Flex/Bison build process managed by the Makefile.

| Command | Description |
|---------|-------------|
| `make all` or `make` | Generates the lex.yy.c and parser2.tab.c files and compiles the executable uni_parser2. |
| `make run` | Executes the compiled program uni_parser2, using input.txt as the source file and writing the Lexer/Parser output (including results, errors, and warnings) to output.txt. |
| `make clean` | Removes the generated files (uni_parser2, .c, .h). |

#### Execution
```bash
make run
