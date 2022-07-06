all:	main

main:
	as main.s -o main.o -g
	ld main.o -o main

run:
	./main &
	pidof main

stop:
	pkill main -n

discardLog:
	rm key.log

clean:
	rm main main.o
