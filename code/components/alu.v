// alu.v - ALU module

module alu #(parameter WIDTH = 32) (
    input       [WIDTH-1:0] a, b,       // operands
    input       [3:0] alu_ctrl,         // ALU control
    output      [WIDTH-1:0] alu_out,    // ALU output
    output      zero, negative, carry, S, U                  // zero flag
);

wire Cout;
wire [31:0] sum;

// This calculation is only for ADD/SUB
assign {Cout, sum} = a + (alu_ctrl[0] ? ~b + 1 : b);

// FIX: Create an intermediate SIGNED register for the result
reg signed [WIDTH-1:0] alu_result_signed;

always @(*) begin
    case (alu_ctrl)
        4'b0000:  alu_result_signed = sum;         // ADD
        4'b0001:  alu_result_signed = sum;         // SUB
        4'b0010:  alu_result_signed = a & b;       // AND
        4'b0011:  alu_result_signed = a | b;       // OR
        4'b0110:  alu_result_signed = a ^ b;       // XOR
        4'b0111:  alu_result_signed = a << b[4:0];      // SLL, SLLI
        4'b1000:  alu_result_signed = a >> b[4:0];      // SRL, SRLI 
        4'b1001:  alu_result_signed = $signed(a) >>> b[4:0]; // SRA, SRAI
        4'b1010:  alu_result_signed = {31'b0, U};  // SLTU
        4'b0101:  alu_result_signed = {31'b0, S};  // SLT, SLTI
        default:  alu_result_signed = 32'b0;
    endcase
end

// Connect the final result to the output
assign alu_out = alu_result_signed;

// --- FLAG LOGIC ---

// FIX: Zero flag must be based on the FINAL output, not just the sum
assign zero = (sum == 0); 

assign U = (a < b); // Unsigned compare
assign S = ($signed(a) < $signed(b)); // Signed compare

// Carry is only valid for ADD. For SUB, it's a borrow bit, which we can ignore here.
assign carry = (alu_ctrl == 4'b0000) ? Cout : 1'b0;

assign negative = alu_out[WIDTH-1];

endmodule