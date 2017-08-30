TARGET	= rnn
OBJS	= rnn.o

CC		= gcc
CFLAGS		= -O2 #-DDEBUG
LDFLAGS		=
INCLUDES	= -I./
LIBS		= -lm

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)

.c.o:
	$(CC) $(CFLAGS) $(INCLUDES) -c $<

$(OBJS): timer.h

clean:
	rm -rf $(TARGET) $(OBJS) *~ 
