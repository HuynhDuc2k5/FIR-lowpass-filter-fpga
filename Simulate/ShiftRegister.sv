/*

N-order register module 
every positive edge, the input value will be shift
Serial in, parallel out (SIPO)

*/


module ShiftRegister
#(
    parameter int N,
    parameter int bitWidth
)
(  
    input logic                 CLK,
    input logic                 RST,
    input logic                 En,
    input logic signed [(bitWidth-1):0]   Input,

    output logic signed [(bitWidth-1):0]  Output [0:(N-1)]
);

logic signed [0:(bitWidth-1)] Buffer [0:(N-1)] ;

always_ff @(posedge CLK or posedge RST) begin
    if(RST) begin
        for (int i = 0; i < N; i++) begin 
            Buffer[i] <= '0 ;
        end
    end

    else begin 
        //shift if no RST is set
        Buffer[0] <= Input ;

        for (int i = 0; i < (N-1); i++) begin 
            Buffer[i+1] <= Buffer[i] ;        
        end
    end
    
end

//output if enable
always_comb begin
    if (En) begin 
        for (int i = 0; i < N; i++) begin
            Output[i] = Buffer[i] ;
        end

    end

    else begin 
        for (int i = 0; i < N; i++) begin
            Output[i] = '0 ;
        end
    end
end

endmodule
