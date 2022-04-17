# This makefile should be linked to the implementation folder.

CC = gcc
CFLAGS = -O3 -march=native -mtune=native -mcpu=native -I../common

C_SRC = $(wildcard *.c)
C_OBJ = $(patsubst %.c, %.o, $(C_SRC))
S_SRC = $(wildcard *.S)
S_OBJ = $(patsubst %.S, %.o, $(S_SRC))
COMMON_DIR = ../../common
COMMON_OBJ = $(COMMON_DIR)/test.c  $(COMMON_DIR)/mock.c

all: testall.bin benchmark.bin

testall.bin: $(C_OBJ) $(S_OBJ) $(COMMON_OBJ)
	@echo "    CC      $@ [DEBUG, REPS=64]"
	@$(CC) $(CFLAG) -o $@ $^ -DDEBUG -DREPS=64

benchmark.bin: $(C_OBJ) $(S_OBJ) $(COMMON_OBJ)
	@echo "    CC      $@ [REPS=1024]"
	@$(CC) $(CFLAG) -o $@ $^ -DREPS=1024

%.o: %.c
	@echo "    CC      $@"
	@$(CC) $(CFLAGS) -o $@ -c $<

%.o: %.S
	@echo "    CC      $@"
	@$(CC) $(CFLAGS) -o $@ -c $<


.PHONY: clean
clean:
	@echo "    RM      *.o"
	@find . -name \*.o		-type f -exec rm -f {} \;
	@echo "    RM      *.bin"
	@find . -name \*.bin	-type f -exec rm -f {} \;
