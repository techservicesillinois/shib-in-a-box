SRCS := $(wildcard *.m4)
TARGETS := $(patsubst %.m4, %.feature, $(SRCS))

all: $(TARGETS)

elmrsample_shib_off_dbg_off.feature: include/elmrsample_shib_off.m4

elmrsample_shib_off_dbg_on.feature: include/elmrsample_shib_off.m4

%.feature: %.m4
	m4 $*.m4 > $@

clean: 
	-rm -f $(TARGETS)
