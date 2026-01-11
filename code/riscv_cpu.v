
// riscv_cpu.v - single-cycle RISC-V CPU Processor

module riscv_cpu (
    input         clk, reset,
    output [31:0] PC,
    input  [31:0] Instr,
	 output [1:0]  StoreSrcO ,
    output        MemWrite,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result
);

wire        ALUSrc, RegWrite, Jump, zero, negative, carry, S, U;
wire [1:0]  ResultSrc, PCSrc, StoreSrc;
wire [2:0]  ImmSrc;
wire [3:0]  ALUControl;
assign StoreSrcO  =StoreSrc ; 

controller  c   (Instr[6:0], Instr[14:12], Instr[30], zero, negative, carry, S, U,
                ResultSrc, PCSrc, MemWrite, ALUSrc, RegWrite, Jump,
                ImmSrc, ALUControl, StoreSrc);

datapath    dp  (clk, reset, ResultSrc, PCSrc,
                ALUSrc, RegWrite, ImmSrc, ALUControl, StoreSrc,
                zero, negative, carry, S, U, PC, Instr, Mem_WrAddr, Mem_WrData, ReadData, Result);

endmodule

