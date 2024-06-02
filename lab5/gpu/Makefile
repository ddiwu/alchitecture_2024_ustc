CC = nvcc

SRCS = $(wildcard *.cu)
OBJS = $(patsubst %.cu, %.exe, $(SRCS))
LIBS = $(patsubst %.cu, %.lib, $(SRCS))
EXPS = $(patsubst %.cu, %.exp, $(SRCS))

all: $(OBJS)

run:
	-for %%i in ($(OBJS)) do %%i

%.exe: %.cu
	$(CC) -o $@ $<

clean:
	del $(OBJS) $(LIBS) $(EXPS)