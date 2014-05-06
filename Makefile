#**********************************************************
#**
#** LOGRAMM
#** Interpreter
#** 
#** (c) 2009-2014, Dr.Kameleon
#**
#**********************************************************
#** Makefile
#**********************************************************

##================================================
## Setup
##================================================

# Definition

APP 	= lgm

# Environment

OS  	= $(shell uname)
CC    	= gcc
DMD   	= dmd
LEX   	= lex
YACC  	= /usr/local/bin/bison
AWK 	= awk
CLOC 	= cloc
CP    	= cp
MV    	= mv
RM    	= rm
YES 	= yes

# Folders

BIN 	= bin
DOC 	= doc
EXTRAS  = extras
LIB 	= lib
SCRIPTS = scripts
SRC 	= src
TESTS 	= tests

# Flags

CC_CFLAGS	= -c -I${SRC}/parser

D_CFLAGS	= -c -op -I${SRC} -J${SRC} -inline -O -release -noboundscheck
D_LFLAGS	= -m64 -L-lcurl -L-lsqlite3

ifeq (${TARGET}, debug)
D_CFLAGS 	:= $(subst -O -release,,${D_CFLAGS})
D_CFLAGS	:= $(subst -O -noboundscheck,,${D_CFLAGS})
D_CFLAGS 	+= -debug -profile -g -gs -gx # -unittest
endif
ifeq (${TARGET}, profile)
D_CFLAGS 	+= -profile
endif

CLOC_FLAGS 	= --exclude-dir=${BIN},${SRC}/library/yaml,${SRC}/library/warp

# Installation paths

BIN_DEST 	= /usr/local/bin
LIB_DEST 	= /usr/lib/${APP}
MAN_DEST    = /usr/share/man

ifeq (${OS}, Darwin)
CGI_DEST 	= /Applications/XAMPP/cgi-bin
endif
ifeq (${OS}, Linux)
CGI_DEST 	= /usr/lib/cgi-bin
endif

# Files

BINARY	  	= ${BIN}/${APP}

LEXER   	= ${SRC}/parser/logramm.l
GRAMMAR  	= ${SRC}/parser/logramm.y

GEN_SOURCES = lex.yy.c logramm.tab.c logramm.tab.h

CC_FILES	= lex.yy logramm.tab $(basename $(wildcard ${SRC}/parser/*.c))
CC_SOURCES	= $(addsuffix .c,${CC_FILES})
CC_OBJECTS	= $(addsuffix .o,${CC_FILES})

D_FILES 	= $(basename $(wildcard ${SRC}/*.d) \
						 $(wildcard ${SRC}/backend/*.d) \
						 $(wildcard ${SRC}/components/*.d) \
						 $(wildcard ${SRC}/library/*.d) \
						 $(wildcard ${SRC}/library/yaml/*.d) \
						 $(wildcard ${SRC}/library/warp/*.d) \
						 $(wildcard ${SRC}/system/*.d) \
			   )

D_SOURCES 	= $(addsuffix .d, ${D_FILES})
D_OBJECTS	= $(addsuffix .o, ${D_FILES})

TRACE_LOGS 	= *.log *.def

MAN_APP	 	= ${DOC}/man/lgm.1
MAN_LIB  	= ${DOC}/man/lgmlib.3

UPDATEBUILD	= ${SCRIPTS}/update-build.awk
BUILDNO 	= ${SRC}/resources/build.txt
BUILDNO_NEW	= ${SRC}/resources/build.new

##================================================
## Rules
##================================================

all: update-build ${BINARY}
	${RM} -f ${GEN_SOURCES}

${BINARY}: ${CC_OBJECTS} ${D_OBJECTS}
	${DMD} $^ -of$@ ${D_LFLAGS}

${D_OBJECTS}: ${D_SOURCES}
	${DMD} ${D_SOURCES} ${D_CFLAGS}

${CC_OBJECTS}: %.o: %.c
	${CC} $< ${CC_CFLAGS} -o $@

${CC_OBJECTS}: ${CC_SOURCES}

${CC_SOURCES}:
	${LEX} ${LEXER}
	${YACC} -d ${GRAMMAR}

install:
	${RM} -rf ${BIN_DEST}/${APP}
	${CP} -rf ${BINARY} ${BIN_DEST}
	${RM} -rf ${CGI_DEST}/${APP}
	${CP} -rf ${BINARY} ${CGI_DEST}
	${RM} -rf ${LIB_DEST}
	${CP} -rf ${LIB} ${LIB_DEST}
	${CP} -rf ${MAN_APP} ${MAN_DEST}/man1
	${CP} -rf ${MAN_LIB} ${MAN_DEST}/man3

clean:
	${RM} -f ${BINARY} ${GEN_SOURCES} ${CC_OBJECTS} ${D_OBJECTS} ${TRACE_LOGS}

count:
	${CLOC} . ${CLOC_FLAGS}

countall:
	${CLOC} .

update-build:
	${AWK} -f ${UPDATEBUILD} < ${BUILDNO} > ${BUILDNO_NEW}
	${YES} | ${RM} -rf ${BUILDNO}
	${MV} ${BUILDNO_NEW} ${BUILDNO}

docs:
	${APP} ${SCRIPTS}/create_doc_html.lgm ${DOC}/html
	${APP} ${SCRIPTS}/create_doc_man.lgm ${DOC}/man
	${APP} ${SCRIPTS}/create_sublime_completions.lgm ${EXTRAS}/highlighting/sublime

test:
	${APP} ${SCRIPTS}/run_unittests.lgm

