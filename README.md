# Lexical & Syntax Analyzer for CLIPS/Lisp-like Language

## Project & Group Information
Αυτό το έργο αναπτύχθηκε ως ομαδική εργασία για την εκπλήρωση των εργαστηριακών απαιτήσεων του μαθήματος **Μεταγλωττιστές (Compilers)**.

- **Course:** Compilers (Μεταγλωττιστές)  
- **Context:** Group Project for Course Requirements  
- **Participants:** 5 μέλη  

## Overview and Functionality
Το έργο υλοποιεί έναν **Lexical Analyzer (Lexer)** και έναν **Syntax Analyzer (Parser)** χρησιμοποιώντας τα εργαλεία **Flex** και **Bison**, αντίστοιχα.  
Η γλώσσα στόχος βασίζεται σε **S-expressions**, παρόμοια με CLIPS ή Lisp.

---

### 1. Lexical Analyzer (Lexer - `all_tokens2.l`)
Ο Lexer είναι υπεύθυνος για την αναγνώριση των tokens στο input αρχείο, όπως:

- **Keywords:** `deffacts`, `defrule`, `bind`, `test`, `read`, `printout`  
- **Constants:**  
  - Integers (`INTCONST`)  
  - Floats (`FLOAT_RE`)  
  - Scientific Notation Integers (`INT_EXP_RE`)  
- **Variables:** Ξεκινούν με `?` (π.χ., `?var`)  
- **Operators & Delimiters:**  
  - Arithmetic: `+`, `-`, `*`, `/`  
  - Equality: `=`  
  - Rule separator: `->`  
  - Parentheses: `(`, `)`  
- **Comments:** Ξεκινάνε με `;` και αγνοούνται από τον parser  

---

### 2. Syntax Analyzer (Parser - `parser2.y`)
Ο Parser επιβλέπει τη σύνταξη και εκτελεί βασικές **semantic actions**:

- **Declarations:** Υποστηρίζει έγκυρες **fact expressions** και top-level declarations (`deffacts`, `defrule`)  
- **Arithmetic Operations:** Υποστηρίζει `+`, `-`, `*`, `/` με πολλαπλούς τελεστέους  
- **Division:** Ελέγχει για **διαίρεση με μηδέν** και υπολογίζει το υπόλοιπο για ακέραια διαίρεση  
- **Variable Binding:** Η εντολή `bind` εκχωρεί ακέραιες τιμές ή αποτελέσματα υπολογισμών σε μετα
