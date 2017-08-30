TARGET	= traverse2
OBJS	= traverse2.o

CC		= gcc
CFLAGS		= -O2
LDFLAGS		=
INCLUDES	= -I./
LIBS		= -lm -lpthread

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

$(OBJS): timer.h

.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) -c $<

clean:
	rm -rf $(TARGET) $(OBJS) *~

