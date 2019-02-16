CX65 = ../cc65/bin
CC65 = $(CX65)/cc65.exe
CA65 = $(CX65)/ca65.exe
LD65 = $(CX65)/ld65.exe
BF = tools/bfcompiler.exe
EMU = ../tools/mesen/mesen.exe
LP = lprun

all: game.nes

clean:
	del *.nes *.dbg
	del src\*.o src\*.s

run:
	$(EMU) game.nes

bf:
	@ $(BF) BF_src1 src/helloworld.b src/helloworld.s
	@ $(CA65) -g src/helloworld.s
	@ $(BF) BF_src2 src/factorial.b src/factorial.s
	@ $(CA65) -g src/factorial.s
	@ $(BF) BF_src3 src/99bottles.b src/99bottles.s
	@ $(CA65) -g src/99bottles.s
%.o: src/%.asm
	@ $(CA65) -g $<

game.nes: header.o boot.o main.o ppu.o lib.o bf.o bf
	@ $(LD65) --dbgfile game.dbg -m game.map -C nes.cfg -o game.nes src/boot.o src/main.o src/header.o src/ppu.o src/lib.o src/bf.o src/helloworld.o src/factorial.o src/99bottles.o

