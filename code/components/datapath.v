
// datapath.v
module datapath (
    input         clk, reset,
    input [1:0]   ResultSrc,
    input [1:0]   PCSrc,
	 input         ALUSrc,
    input         RegWrite,
    input [2:0]   ImmSrc,
    input [3:0]   ALUControl,
	 input [1:0]   StoreSrc,
    output        zero, negative, carry, S, U,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result
);

wire [31:0] PCNext, PCPlus4, PCTarget;
wire [31:0] ImmExt,SrcA, SrcB, WriteData,ALUResult ,lui_or_auipc , ReadDataTemp;

// next PC logic
reset_ff #(32) pcreg(clk, reset, PCNext, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);
adder          pcaddbranch(PC, ImmExt, PCTarget);
mux4 #(32)     pcmux(PCPlus4, PCTarget, ALUResult, PCPlus4, PCSrc, PCNext);

// register file logic
reg_file       rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
imm_extend     ext (Instr[31:7], ImmSrc, ImmExt);

mux5 #(32)     lw_variationmux({{24{ReadData[7]}}, ReadData[7:0]} , {{16{ReadData[15]}}, ReadData[15:0]} ,
               ReadData, {24'b0, ReadData[7:0]}, {16'b0, ReadData[15:0]}, Instr[14:12], ReadDataTemp); 
mux2 #(32)     lui_or_auipcmux(PCTarget, ImmExt, Instr[5], lui_or_auipc);
// ALU logic
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
alu            alu (SrcA, SrcB, ALUControl, ALUResult, zero, negative, carry, S, U);
mux4 #(32)     resultmux(ALUResult, ReadDataTemp, PCPlus4, lui_or_auipc, ResultSrc, Result);

assign Mem_WrData = WriteData;
assign Mem_WrAddr = ALUResult;

endmodule

