CXX=g++
BISON=bison
FLEX=flex
TARGET=scr_sample
OBJS=Parser.o Scanner.o ParseDriver.o main.o


CFLAGS=-g -std=c++11 -Wno-deprecated-register

$(TARGET): $(OBJS)
	$(CXX) $(OBJS) $(CFLAGS) -o $@

Parser.cpp: Parser.y
	$(BISON) -o $@ $<

Scanner.cpp: Scanner.l
	$(FLEX) -o $@ $<

.SUFFIXES:.cpp.o
.cpp.o:
	$(CXX) $(CFLAGS) -c $<

clean:
	rm -f $(OBJS) location.hh position.hh stack.hh Parser.cpp Parser.hpp Scanner.cpp




