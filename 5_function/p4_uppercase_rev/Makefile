UPPEROBJS = main.o upper.o
ifdef DEBUG 
DEBUGFLGS = -g 
else
DEBUGFLGS = 
endif
LSTFLGS = 
all: upper 
%.o : %.s
	as $(DEBUGFLGS) $(LSTFLGS) $< -o $@
	echo $(DEBUGFLGS)
upper: $(UPPEROBJS)
	ld -o upper $(UPPEROBJS)