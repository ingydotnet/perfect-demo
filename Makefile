# Make sure we have 'git' and it works OK:
ifeq ($(shell which git),)
    $(error 'git' is not installed on this system)
endif
GITVER ?= $(word 3,$(shell git --version))

NAME = perfect-demo
LIB = lib
LIBS = $(shell find $(LIB) -type f) \
	$(shell find $(LIB) -type l)
DOC = doc/$(NAME).swim
DOCS = $(shell echo doc/*)
# MAN = $(MAN1)/$(NAME).1
MAN1 = man/man1
MANS = $(DOCS:doc/%.swim=$(MAN1)/%.1)
EXT = $(LIB)/$(NAME).d
EXTS = $(shell find $(EXT) -type f) \
	$(shell find $(EXT) -type l)
SHARE = share

# # XXX Make these vars look like git.git/Makefile style
# PREFIX ?= /usr/local
# # XXX Using sed for now. Would like to use bash or make syntax.
# # If GIT_EXEC_PATH is set, `git --exec-path` will contain that appended to the
# # front. We just want the path where git is actually installed:
# INSTALL_LIB ?= $(shell git --exec-path | sed 's/.*://')
# INSTALL_CMD ?= $(INSTALL_LIB)/$(NAME)
# INSTALL_EXT ?= $(INSTALL_LIB)/$(NAME).d
# INSTALL_MAN1 ?= $(PREFIX)/share/man/man1

##
# User targets:
default: help

help:
	@echo 'Makefile rules:'
	@echo ''
	@echo '    doc        Generate the docs/manpages'
	@echo '    test       Run all tests'
	@echo ''
# 	@echo 'install    Install $(NAME)'
# 	@echo 'uninstall  Uninstall $(NAME)'

.PHONY: test
test:
ifeq ($(shell which prove),)
	@echo '`make test` requires the `prove` utility'
	@exit 1
endif
	prove $(PROVEOPT:%=% )test/

# install: install-lib install-doc
# 
# install-lib: $(INSTALL_EXT)
# 	install -C -m 0755 $(LIBS) $(INSTALL_LIB)/
# 	install -d -m 0755 $(INSTALL_EXT)/
# 	install -C -m 0755 $(EXTS) $(INSTALL_EXT)/
# 
# install-doc:
# 	install -d -m 0755 $(INSTALL_MAN1)
# 	install -C -m 0644 $(MAN) $(INSTALL_MAN1)
# 
# uninstall: uninstall-lib uninstall-doc
# 
# uninstall-lib:
# 	rm -f $(INSTALL_CMD)
# 	rm -fr $(INSTALL_EXT)
# 
# uninstall-doc:
# 	rm -f $(INSTALL_MAN1)/$(NAME).1
# 
# $(INSTALL_EXT):
# 	mkdir -p $@

clean purge:
	git clean -fxd

##
# Build rules:

# update: doc compgen
update: doc

# doc: ReadMe.pod
#
# ReadMe.pod: doc/hp-paas-tools.swim
# 	swim --to=pod --complete --wrap $< > $@

doc: swim-check $(MAN1) $(MANS) ReadMe.pod
# 	perl tool/generate-help-functions.pl $(DOC) > \
# 	    $(EXT)/help-functions.bash

# compgen:
# 	perl tool/generate-completion.pl bash $(DOC) $(LIB)/git-hub > \
# 	    $(SHARE)/completion.bash
# 	perl tool/generate-completion.pl zsh $(DOC) $(LIB)/git-hub > \
# 	    $(SHARE)/zsh-completion/_git-hub

$(MAN1)/%.1: doc/%.swim
	swim --to=man $< > $@

$(MAN1):
	mkdir -p $(MAN1)

ReadMe.pod: $(DOC)
	swim --to=pod --complete --wrap $< > $@

swim-check:
	@# Need to assert Swim and Swim::Plugin::badge are installed
