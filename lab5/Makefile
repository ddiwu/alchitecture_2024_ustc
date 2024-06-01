CC = gcc
CFLAGS = -mavx -march=native

SRCS = $(wildcard *.cpp)
OBJS = $(patsubst %.cpp, %.exe, $(SRCS))

all: $(OBJS)

%.exe: %.cpp
	$(CC) $(CFLAGS) -o $@ $<

clean: 
	del $(OBJS)