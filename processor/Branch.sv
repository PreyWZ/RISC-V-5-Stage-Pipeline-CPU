//分岐

import BasicTypes::*;
import Types::*;

module Branch(
    input br_func3_type br_func3,
    input logic isBran,
    input logic isJal,
    input logic isJalr,
    input InsnAddrPath pcIns,
    input DataPath imm,
    input DataPath dataA,
    input DataPath dataB,
    input logic clk,


    output logic jumpEnable,
    output InsnAddrPath jumpTarget,
    output DataPath linkAddr
);
    DataPath pcExtend;
    DataPath immFull;
    DataPath jalrTarget;

    assign pcExtend={{(DATA_WIDTH-INSN_ADDR_WIDTH){1'b0}},pcIns};
    assign immFull=pcExtend+imm;
    assign jalrTarget=dataA+imm;

    always_comb  begin
        jumpEnable=1'b0;
        jumpTarget='0;
        linkAddr=pcExtend+INSN_PC_INC;

        if(isJal) begin
            jumpEnable=1'b1;
            jumpTarget=immFull[INSN_ADDR_WIDTH-1:0];
        end
        else if(isJalr) begin
            jumpEnable=1'b1;
            jumpTarget={jalrTarget[INSN_ADDR_WIDTH-1:1],1'b0};
        end
        else if (isBran) begin
            jumpTarget=immFull[INSN_ADDR_WIDTH-1:0];
            case (br_func3)
                BR_BEQ: jumpEnable= (dataA == dataB);
                BR_BNE: jumpEnable= (dataA != dataB);
                BR_BLT: jumpEnable= ($signed(dataA) < $signed(dataB));
                BR_BGE: jumpEnable= ($signed(dataA) >= $signed(dataB));
                default:jumpEnable=1'b0;
            endcase
        end
    end

endmodule