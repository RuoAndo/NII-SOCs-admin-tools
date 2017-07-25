TARGET	= traverse2
OBJS	= traverse2.o

CC		= g++
CFLAGS		= -O2 -fpermissive
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

