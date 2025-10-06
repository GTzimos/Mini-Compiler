# Makefile for uni_parser2

# Compiler and flags
CC = gcc
CFLAGS = -Wall
LDFLAGS = -lfl

# Targets
TARGET = uni_parser2

# Files
LEX_SRC = all_tokens2.l
YACC_SRC = parser2.y
YACC_OUT = parser2.tab.c parser2.tab.h
LEX_OUT = lex.yy.c

INPUT = input.txt
OUTPUT = output.txt

all: $(TARGET)

$(TARGET): parser2.tab.c lex.yy.c
	$(CC) -o $@ $^ $(LDFLAGS)

parser2.tab.c: $(YACC_SRC)
	bison -d $<

lex.yy.c: $(LEX_SRC)
	flex $<

run: $(TARGET)
	./$(TARGET) $(INPUT) $(OUTPUT)

clean:
	rm -f $(TARGET) $(YACC_OUT) $(LEX_OUT)

.PHONY: all run clean