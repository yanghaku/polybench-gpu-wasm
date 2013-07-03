#
# Copyright 2008 - 2012 CAPS entreprise. All rights reserved.
#
ATI_DISPLAY    = DISPLAY=:0.0

GCC            = gcc 
ICC            = icc
HMPP           = hmpp #-Xnvcc \"-gencode=arch=compute_13,code="sm_13,compute_13"\"  -Xnvcc \"-gencode=arch=compute_20,code=""sm_20,compute_20""\"  -Xnvcc \"-gencode=arch=compute_30,code=""sm_30,compute_30""\" -Xnvcc \"-gencode=arch=compute_35,code=""sm_35,compute_35""\"

GCC_FLAGS      = -std=c99
CFLAGS         = -O2 -p -w 
CPPFLAGS       = -I../../../common
LDFLAGS        =
HMPPFLAGS      = --codelet-required

VPATH          = ../../../common

CLEANFILES     = *.exe *.hmg* *.hmc* *.out *.dpil* *.mod*

BIN	       = lab

## choose your compiler here ##
CC	       = $(GCC)

#ifeq($(CC),$(GCC))
FLAGS  = $(GCC_FLAGS) -std=c99
#else
#FLAGS  = $(ICC_FLAGS)
#endif

.DEFAULT: all

all: run

exe: $(BIN).exe

run: exe
	$(ATI_DISPLAY) ./$(BIN).exe

verbose:
	$(MAKE) $(BIN).exe DFLAGS="-k -d"
	$(MAKE) run HMPP_VERBOSITY=9
	$(GPROF) ./$(BIN).exe

%.exe: %.c $(DEPS)
	$(HMPP) $(HMPPFLAGS) $(DFLAGS) $(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) $(CPPFLAGS) $(LDFLAGS) -c $< -o $@

clean:
	rm -f $(CLEANFILES)

help: 	
	@echo "#"
	@echo "# Copyright 2008 - 2010 CAPS entreprise. All rights reserved."
	@echo "#"
	@echo ""
	@echo "Targets available are :"
	@echo ""
	@echo " make all     : compiles and runs the application"
	@echo ""
	@echo " make exe     : compiles the application"
	@echo ""
	@echo " make run     : runs the execution"
	@echo ""
	@echo " make verbose : compiles and launches the execution with the higher level of verbosity"
	@echo ""
	@echo " make clean   : deletes files generated by make"
	@echo ""
