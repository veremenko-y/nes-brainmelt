CX65 = ../cc65/bin
CC65 = $(CX65)/cc65.exe
CA65 = $(CX65)/ca65.exe
LD65 = $(CX65)/ld65.exe
EMU = ../tools/mesen/mesen.exe
LP = lprun

all: game.nes

clean:
	del *.nes *.dbg
	del src\*.o

run:
	$(EMU) game.nes

%.o: src/%.asm
	@ $(CA65) -g $<

game.nes: header.o boot.o main.o ppu.o lib.o bf.o
	@ $(LD65) --dbgfile game.dbg -m game.map -C nes.cfg -o game.nes src/boot.o src/main.o src/header.o src/ppu.o src/lib.o src/bf.o

