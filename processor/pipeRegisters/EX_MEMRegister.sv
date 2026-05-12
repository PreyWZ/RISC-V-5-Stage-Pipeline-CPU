import BasicTypes::*;
import Types::*;
module EX_MEMRegister (
    input logic clk,
    input logic rst,

    input logic regWrEnable_i,
    input logic memWrEnable_i,
    input logic memToReg_i,

    input DataPath aluResult_i,
    input DataPath memData_i,
    input RegNumPath rd_i,

    output logic regWrEnable_o,
    output logic memWrEnable_o,
    output logic memToReg_o,

    output DataPath aluResult_o,
    output DataPath memData_o,
    output RegNumPath rd_o

);
    always_ff @( posedge clk or posedge rst  ) begin
        if (rst) begin
            regWrEnable_o <= '0;
            memWrEnable_o <= '0;
            memToReg_o <= 1'b0;
            aluResult_o <= '0;
            memData_o<='0;
            rd_o<='0;
        end
        else begin
            regWrEnable_o<=regWrEnable_i;
            memWrEnable_o<=memWrEnable_i;
            memToReg_o<=memToReg_i;
            aluResult_o<=aluResult_i;
            memData_o<=memData_i;
            rd_o<=rd_i;           
        end

    end
    
endmodule