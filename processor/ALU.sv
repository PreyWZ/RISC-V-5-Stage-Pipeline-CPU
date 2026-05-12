
import BasicTypes::*;
import Types::*;

module ALU(
    output DataPath res,

    input DataPath dataA,
    input DataPath dataB,

    input logic clk,
    input CtrALU ctr
    
);


always_comb begin
    case (ctr)
        ALU_AND    :  res = dataA & dataB;
        ALU_OR     :  res = dataA | dataB;
        ALU_ADD    :  res = dataA + dataB;
        ALU_SUB    :  res = dataA - dataB;
        ALU_XOR    :  res = dataA ^ dataB;
        ALU_SLT    :  res = ($signed(dataA) < $signed(dataB))? 32'b1:32'b0;
        ALU_LUI    :  res = dataB;
        default    :  res='0;
    endcase
end


endmodule