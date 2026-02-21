CC = gcc
CFLAGS = -Wall

all: client serveur

client: simpleClientSocket.o client.o
	$(CC) $(CFLAGS) -o client simpleClientSocket.o client.o

serveur: simpleServerSocket.o
	$(CC) $(CFLAGS) -o serveur simpleServerSocket.o

simpleClientSocket.o: simpleClientSocket.c client.h
	$(CC) $(CFLAGS) -c simpleClientSocket.c

client.o: client.c client.h
	$(CC) $(CFLAGS) -c client.c

simpleServerSocket.o: simpleServerSocket.c
	$(CC) $(CFLAGS) -c simpleServerSocket.c

clean:
	rm -f *.o client serveur
