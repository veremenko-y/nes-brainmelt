using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace bfcompiler
{
    internal class Program
    {
        private static void Main(string[] args)
        {
            if (args.Length != 3)
            {
                Console.WriteLine("Usage: bfcompier [exportlabel] [input] [output]");
                return;
            }
            var src = File.ReadAllText(args[1]);
            var output = new StringBuilder();
			output.AppendLine(".include \"bf.inc\"");
            output.AppendLine(".export " + args[0]);
            output.AppendLine(args[0] + ":");
            var currentLabel = 1;
            var labelStack = new Stack<int>();
            var size = 0;
            for (var i = 0; i < src.Length; i++)
            {
                if (src[i] != '<' && src[i] != '>' && src[i] != '+' && src[i] != '-' && src[i] != '[' && src[i] != ']' && src[i] != ',' && src[i] != '.')
                    continue;

                if (src[i] == '.')
                {
                    output.AppendLine(".byte OP_BF_PRINT");
                    ++size;
                }
                else if (src[i] == ',')
                {
                    output.AppendLine(".byte OP_BF_READ");
                    ++size;
                }
                else if (src[i] == '[')
                {
                    output.AppendLine("BF_LABEL" + currentLabel + ":");
                    output.AppendLine(".byte OP_BF_CONDITION");


                    output.AppendLine(".word BF_LABEL_END" + currentLabel);
                    labelStack.Push(currentLabel);
                    ++currentLabel;
                    size += 3;
                }
                else if (src[i] == ']')
                {
                    output.AppendLine(".byte OP_BF_JMP");
                    var endLabel = labelStack.Pop();
                    output.AppendLine(".word BF_LABEL" + endLabel);
                    output.AppendLine("BF_LABEL_END" + endLabel + ":");
                    size += 3;
                }
                else
                {
                    var currentChar = src[i];
                    var repeat = 1;
                    while ((i + 1) < src.Length && currentChar == src[i + 1] && repeat < 255)
                    {
                        ++repeat;
                        ++i;
                    }
                    if (src[i] == '>')
                    {
                        if (repeat == 1)
                        {
                            output.AppendLine(".byte OP_BF_INCP");
                            ++size;
                        }
                        else
                        {
                            output.AppendLine(".byte OP_BF_INCP_MULTI");
                            output.AppendLine(".byte " + repeat);
                            size += 2;
                        }
                    }
                    else if (src[i] == '<')
                    {
                        if (repeat == 1)
                        {
                            output.AppendLine(".byte OP_BF_DECP");
                            ++size;
                        }
                        else
                        {
                            output.AppendLine(".byte OP_BF_DECP_MULTI");
                            output.AppendLine(".byte " + repeat);
                            size += 2;
                        }
                    }
                    else if (src[i] == '+')
                    {
                        if (repeat == 1)
                        {
                            output.AppendLine(".byte OP_BF_INC");
                            ++size;
                        }
                        else
                        {
                            output.AppendLine(".byte OP_BF_INC_MULTI");
                            output.AppendLine(".byte " + repeat);
                            size += 2;
                        }
                    }
                    else if (src[i] == '-')
                    {
                        if (repeat == 1)
                        {
                            output.AppendLine(".byte OP_BF_DEC");
                            ++size;
                        }
                        else
                        {
                            output.AppendLine(".byte OP_BF_DEC_MULTI");
                            output.AppendLine(".byte " + repeat);
                            size += 2;
                        }
                    }
                }
            }
            output.AppendLine(".byte OP_BF_END");
            File.WriteAllText(args[2], output.ToString());
            Console.WriteLine("Brainfuck sucessfuly compiled. Size: " + size + " bytes");
        }
    }
}
