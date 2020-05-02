OBJS_DIR = .objs
CC = clang
WARNINGS = -Wall -Wextra -Werror -Wno-error=unused-parameter -Wmissing-declarations -Wmissing-variable-declarations
CFLAGS_COMMON = $(WARNINGS) -std=c99
CFLAGS_RELEASE = $(CFLAGS_COMMON) -O2
CFLAGS_DEBUG = $(CFLAGS_COMMON) -O0 -g -DDEBUG

.PHONY: clean

accelerator_example: $(OBJS_DIR)/accelerator_lib.o $(OBJS_DIR)/util.o accelerator_example.c $(OBJS_DIR)
	$(CC) $(CFLAGS_RELEASE) accelerator_example.c $(OBJS_DIR)/accelerator_lib.o $(OBJS_DIR)/util.o -o accelerator_example

$(OBJS_DIR)/accelerator_lib.o: accelerator_lib.c accelerator_lib.h $(OBJS_DIR)/util.o $(OBJS_DIR)
	$(CC) $(CFLAGS_RELEASE) -c accelerator_lib.c -o $(OBJS_DIR)/accelerator_lib.o

$(OBJS_DIR)/util.o: util/util.c util/util.h $(OBJS_DIR)
	$(CC) $(CFLAGS_RELEASE) -c util/util.c -o $(OBJS_DIR)/util.o

$(OBJS_DIR):
	mkdir $(OBJS_DIR)

clean:
	rm -r $(OBJS_DIR) accelerator_example
