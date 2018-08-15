CC = cc
CFLAGS = -O2 -homp
SRC = vtk_export.c shwater2d.c
OBJS = ${SRC:.c=.o}
DEST = shwater2d

all: $(DEST)

$(DEST): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@ -lm	

clean:
	rm -f $(DEST) *.mod *.MOD *.o

%.o: %.c
	$(CC) $(CFLAGS) -c $<

