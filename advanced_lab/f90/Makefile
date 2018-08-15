FC = ftn
ifeq ($(CRAY_PRGENVCRAY), loaded)
FFLAGS = -O2 -homp
else ifeq ($(CRAY_PRGENVINTEL), loaded)
FFLAGS = -O2 -openmp
else ifeq ($(CRAY_PRGENVGNU), loaded)
ifeq ($(shell expr $(GCC_VERSION) '<' 5.0), 1)
$(error Unsupported GCC version, use at least v5.x (module swap gcc gcc/5.1.0))
endif
FFLAGS = -O2 -fopenmp
else
FFLAGS = -O2
endif
SRC = vtk_export.f90 shwater2d.f90
OBJS = ${SRC:.f90=.o}
DEST = shwater2d

all: $(DEST)

$(DEST): $(OBJS)
	$(FC) $(FFLAGS) $(OBJS) -o $@	

clean:
	rm -f $(DEST) *.mod *.MOD *.o

%.o: %.f90
	$(FC) $(FFLAGS) -c $<

