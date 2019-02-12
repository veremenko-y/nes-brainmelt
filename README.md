# NES Brainfuck

Brainfuck VM for NES. Uses ca65 macroses to generate binary for supplied Brainfuck code. Read operator is not supported.

## Examples

```
; Hello World
BF_run:
BF_compile "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."
jsr BF_run
```
Result:

![Hello World](/info/hello_world.png)

```
; Factorial
BF_run:
BF_compile "+++++++++++++++++++++++++++++++++>+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>++++++++++>++++++>>+<<[>++++++++++++++++++++++++++++++++++++++++++++++++.------------------------------------------------<<<<.-.>.<.+>>>>>>>++++++++++<<[->+>-[>+>>]>[+[-<+>]>+>>]<<<<<<]>[<+>-]>[-]>>>++++++++++<[->-[>+>>]>[+[-<+>]>+>>]<<<<<]>[-]>>[++++++++++++++++++++++++++++++++++++++++++++++++.[-]]<[++++++++++++++++++++++++++++++++++++++++++++++++.[-]]<<<++++++++++++++++++++++++++++++++++++++++++++++++.[-]<<<<<<.>>+>[>>+<<-]>>[<<<[>+>+<<-]>>[<<+>>-]>-]<<<<-]"
jsr BF_run
```

Result:

![Factorial](/info/factorial.png)