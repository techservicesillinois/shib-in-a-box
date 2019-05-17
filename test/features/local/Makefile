DIRS := $(wildcard dev*) $(wildcard prod*)
TEST := $(DIRS:%=%.test)
DOWN := $(DIRS:%=%.down)
CLEAN := features.clean $(DIRS:%=%.clean)

# MAKEFLAGS='-j 2'

.PHONY: all clean features $(DIRS) $(CLEAN)

all: $(DIRS)

$(DIRS): features

features $(DIRS):
	$(MAKE) -C $@

test: $(TEST)

$(TEST): %.test:
	$(MAKE) -C $* test
	$(MAKE) -C $* down

down: $(DOWN)

$(DOWN): %.down:
	$(MAKE) -C $* down

clean: $(CLEAN)

$(CLEAN): %.clean:
	$(MAKE) -C $* clean
