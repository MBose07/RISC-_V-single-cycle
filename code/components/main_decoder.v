// main_decoder.v - logic for main decoder

module main_decoder (
    input  [6:0] op,
    input  [2:0] funct3,
    input        zero, negative, carry, S, U,
    output reg [1:0] ResultSrc, PCSrc,
    output reg       MemWrite, Branch, ALUSrc,
    output reg       RegWrite, Jump,
    output reg [2:0] ImmSrc,
    output reg [1:0] ALUOp,
    output reg       op3, op5,
    output reg [1:0] StoreSrc
);

// Internal wire for branch condition logic
wire Branch_condition;

// Branch condition logic remains combinational for clarity
assign Branch_condition = (funct3 == 3'b000 && zero) || //BEQ
                        (funct3 == 3'b001 && !zero) || //BNE
                        (funct3 == 3'b100 && S) ||     //BLT
                        (funct3 == 3'b101 && !S) ||     //BGE
                        (funct3 == 3'b110 && U) ||     //BLTU
                        (funct3 == 3'b111 && !U);      //BGEU

always @(*) begin

    ResultSrc = 2'b00;
    PCSrc     = 2'b00;
    MemWrite  = 1'b0;
    ALUSrc    = 1'b1;
    RegWrite  = 1'b0;
    Jump      = 1'b0;
    ImmSrc    = 3'b000;
    ALUOp     = 2'b10; // Default to R-type operations
    StoreSrc  = 2'b11; // Default
    Branch    = 1'b0;
    op3       = op[3];
    op5       = op[5];

    // Decode based on the opcode
    case(op)
        7'b0110011: begin // R-type
            ResultSrc = 2'b00;
            ALUSrc    = 1'b0;
            RegWrite  = 1'b1;
            ALUOp     = 2'b10;
        end
        7'b0010011: begin // I-type (immediate arithmetic)
            ResultSrc = 2'b00;
            ALUSrc    = 1'b1;
            RegWrite  = 1'b1;
            ImmSrc    = 3'b000;
            ALUOp     = 2'b10;
        end
        7'b0000011: begin // I-type (load)
            ResultSrc = 2'b01;
            ALUSrc    = 1'b1;
            RegWrite  = 1'b1;
            ImmSrc    = 3'b000;
            ALUOp     = 2'b00; // ALU performs addition for address calculation
        end
        7'b0100011: begin // S-type (store)
            MemWrite  = 1'b1;
            ALUSrc    = 1'b1;
            ImmSrc    = 3'b001;
            ALUOp     = 2'b00; // ALU performs addition for address calculation
            case(funct3)
                3'b000: StoreSrc = 2'b00; // sb
                3'b001: StoreSrc = 2'b01; // sh
                3'b010: StoreSrc = 2'b10; // sw
                default: StoreSrc = 2'b11;
            endcase
        end
        7'b1100011: begin // B-type (branch)
            ALUSrc    = 1'b0;
            ImmSrc    = 3'b010;
            ALUOp     = 2'b01; // ALU performs subtraction/comparison
            Branch    = Branch_condition;
        end
        7'b0110111: begin // U-type (LUI)
            ResultSrc = 2'b11;
            RegWrite  = 1'b1;
            ImmSrc    = 3'b100;
        end
        7'b0010111: begin // U-type (AUIPC)
            ResultSrc = 2'b11;
            RegWrite  = 1'b1;
            ImmSrc    = 3'b100;
        end
        7'b1101111: begin // J-type (JAL)
            ResultSrc = 2'b10;
            RegWrite  = 1'b1;
            Jump      = 1'b1;
            ImmSrc    = 3'b011;
        end
        7'b1100111: begin // I-type (JALR)
            ResultSrc = 2'b10;
            RegWrite  = 1'b1;
            Jump      = 1'b1;
            ImmSrc    = 3'b000;
        end
        default: begin
            // Keep default values for unknown opcodes
        end
    endcase

    // PC source logic based on Jump and Branch signals
    if (Jump) begin
        if (op[3]) // JAL
            PCSrc = 2'b01;
        else // JALR
            PCSrc = 2'b10;
    end else if (Branch) begin
        PCSrc = 2'b01;
    end else begin
        PCSrc = 2'b00;
    end
end

endmodule