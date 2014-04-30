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

OS 		= $(shell uname)
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

CC_CFLAGS	= -c

D_CFLAGS	= -c -op -I${SRC} -J${SRC} -inline -O -release
D_LFLAGS	= -m64 -L-lcurl -L-lsqlite3

ifeq (${TARGET}, debug)
D_CFLAGS 	:= $(subst -O -release,,${D_CFLAGS})
D_CFLAGS 	+= -debug -unittest -profile -g -gs -gx
endif
ifeq (${TARGET}, profile)
D_CFLAGS 	+= -profile
endif

CLOC_FLAGS 	= --exclude-dir=${BIN}

# Installation paths

BIN_DEST 	= /usr/local/bin
LIB_DEST 	= /usr/lib/${APP}

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

CC_FILES	= lex.yy logramm.tab
CC_HEADER	= logramm.tab.h
CC_SOURCES	= $(addsuffix .c,${CC_FILES})
CC_OBJECTS	= $(addsuffix .o,${CC_FILES})

D_FILES 	= $(basename $(wildcard ${SRC}/*.d))
D_SOURCES 	= $(addsuffix .d, ${D_FILES})
D_OBJECTS	= $(addsuffix .o, ${D_FILES})

TRACE_LOGS 	= *.log *.def

UPDATEBUILD	= ${SCRIPTS}/update-build.awk
BUILDNO 	= ${SRC}/build.txt
BUILDNO_NEW	= ${SRC}/build.new

##================================================
## Rules
##================================================

all: update-build ${BINARY}
	${RM} -f ${CC_SOURCES} ${CC_HEADER}

${BINARY}: ${CC_OBJECTS} ${D_OBJECTS}
	${DMD} $^ -of$@ ${D_LFLAGS}

${D_OBJECTS}: ${D_SOURCES}
	${DMD} ${D_SOURCES} ${D_CFLAGS}

${CC_OBJECTS}: %.o: %.c
	${CC} $< ${CC_CFLAGS}

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

clean:
	${RM} -f ${BINARY} ${CC_SOURCES} ${CC_HEADER} ${CC_OBJECTS} ${D_OBJECTS} ${TRACE_LOGS}

count:
	${CLOC} . ${CLOC_FLAGS}

update-build:
	${AWK} -f ${UPDATEBUILD} < ${BUILDNO} > ${BUILDNO_NEW}
	${YES} | ${RM} -rf ${BUILDNO}
	${MV} ${BUILDNO_NEW} ${BUILDNO}

