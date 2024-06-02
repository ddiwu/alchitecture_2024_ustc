CC = gcc
CFLAGS = -mavx -march=native

SRCS = $(wildcard *.cpp)
OBJS = $(patsubst %.cpp, %.exe, $(SRCS))

all: $(OBJS)

run: $(OBJS)
	-for %%i in ($(OBJS)) do %%i

%.exe: %.cpp
	$(CC) $(CFLAGS) -o $@ $<

clean: 
	del $(OBJS)