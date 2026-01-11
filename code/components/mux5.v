module mux5 #(parameter WIDTH = 8) (
    input       [WIDTH-1:0] d0, d1, d2, d3 , d4 ,
    input       [2:0] sel,
    output      [WIDTH-1:0] y
);

 assign y = (sel == 3'b000) ? d0 :
               (sel == 3'b001) ? d1 :
               (sel == 3'b010) ? d2 :
               (sel == 3'b100) ? d3 :
               (sel == 3'b101) ? d4 :{WIDTH {1'b0}} ; 

endmodule