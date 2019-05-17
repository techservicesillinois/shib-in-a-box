# http://blog.jgc.org/2011/07/gnu-make-recursive-wildcard-function.html
rwildcard=$(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2) $(filter $(subst *,%,$2),$d))

ROOT := $(call rwildcard,root,*)
GSRC := get-shib-keys/Makefile get-shib-keys/get-shib-keys.go
SRCS := Dockerfile $(ROOT) $(GSRC) ../base/.image
NAME := shibd-config

include ../Common.mk
