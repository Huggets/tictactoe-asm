.PHONY: clean
.PHONY: mrproper

all: tictactoe

tictactoe: main.o
	ld -o tictactoe main.o

main.o: main.s
	as -o main.o main.s

clean:
	rm -f main.o

mrproper: clean
	rm -f tictactoe
