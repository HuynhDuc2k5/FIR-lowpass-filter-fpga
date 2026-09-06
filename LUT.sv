//coefficient
//store as Q1.15 fixed point signal


module LUT (
    input logic Enable,

    output logic signed [15:0] outCoefficient [0:7]
);

// store coefficient 
logic signed [15:0] coefficient [0:7] ;

initial begin
    coefficient[0] = 16'h027F;
    coefficient[1] = 16'h0832;
    coefficient[2] = 16'h154B;
    coefficient[3] = 16'h2004;
    coefficient[4] = 16'h2004;
    coefficient[5] = 16'h154B;
    coefficient[6] = 16'h0832;
    coefficient[7] = 16'h027F;
end

//operation
always_comb begin
    if(Enable) begin
        for (int i = 0; i < 8; i++) begin
            outCoefficient[i] = coefficient[i]; 
        end
    end

    else begin
        for (int i = 0; i < 8; i++) begin
            outCoefficient[i] = '0; 
        end
    end
end

endmodule