import BasicTypes::*;
import Types::*;
module IF_IDRegister (
    input logic clk,
    input logic rst,
    input InsnAddrPath pc_i,
    input InsnPath insn_i,
    input logic stall,
    input logic flush,

    output InsnAddrPath pc_o,
    output InsnPath insn_o
);
    always_ff @( posedge clk or posedge rst  ) begin
        if (rst) begin 
            insn_o<=INSN_RESET_VECTOR;
            pc_o<=INSN_RESET_VECTOR;
        end
        else if(stall) begin 
            insn_o<=insn_o;
            pc_o<=pc_o;
        end
        else if (flush) begin
            insn_o<='0;
            pc_o<='0;
        end
        else begin
            insn_o<=insn_i;
            pc_o<=pc_i;
        end
    end
endmodule