FEATURES=$(wildcard *.feature)
TESTS=$(FEATURES:%.feature=%)

export BFLAGS=--color

all: $(DEPS)

%.feature:
	@test -e ../features/$@ || (echo ../features/$@: File does not exist! ; exit 1)
	ln -s ../features/$@

$(TOP_LEVEL):
	@test -e ../$@ || (echo ../$@: File does not exist! ; exit 1)
	ln -s ../$@

test:
	@export BFLAGS="-D DISABLE_DOCKER_DOWN $$BFLAGS"; \
	test -f .up && export BFLAGS="-D DISABLE_DOCKER_UP $$BFLAGS"; \
	touch .up; \
    echo behave $$BFLAGS; \
	behave $$BFLAGS

$(TESTS):
	@export BFLAGS="-D DISABLE_DOCKER_DOWN $$BFLAGS"; \
	test -f .up && export BFLAGS="-D DISABLE_DOCKER_UP $$BFLAGS"; \
	touch .up; \
    echo behave $$BFLAGS $@.feature; \
	behave $$BFLAGS $@.feature

down:
	-test -f .up && docker-compose down
	-rm .up

clean: 
	rm -f $(DEPS)
