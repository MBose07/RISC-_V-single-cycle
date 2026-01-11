
// controller.v - controller for RISC-V CPU

module controller (
    input [6:0]  op,
    input [2:0]  funct3,
    input        funct7b5,
    input        zero, negative, carry, S, U,
    output [1:0] ResultSrc, PCSrc,
    output       MemWrite,
    output       ALUSrc,
    output       RegWrite, Jump,
    output [2:0] ImmSrc,
    output [3:0] ALUControl,
	 output [1:0] StoreSrc
);

wire [1:0] ALUOp;
wire       Branch;

main_decoder    md (op, funct3, zero, negative, carry, S, U, ResultSrc, PCSrc, MemWrite, Branch,
                    ALUSrc, RegWrite, Jump, ImmSrc, ALUOp, op3, op5, StoreSrc);

alu_decoder     ad (op[5], funct3, funct7b5, ALUOp, ALUControl);


endmodule

