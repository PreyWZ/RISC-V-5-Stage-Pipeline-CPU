import BasicTypes::*;
import Types::*;
module MEM_WBRegister (
    input logic clk,
    input logic rst,

    input logic wrEnable_i,
    input logic memToReg_i,

    input DataPath aluResult_i,
    input DataPath rdData_i,
    input RegNumPath rd_i,

    output logic wrEnable_o,
    output logic memToReg_o,
    output DataPath aluResult_o,
    output DataPath rdData_o,
    output RegNumPath rd_o
);
    always_ff @( posedge clk or posedge rst  ) begin
        if (rst)begin
            wrEnable_o<='0;
            memToReg_o<='0;
            aluResult_o<='0;
            rdData_o<='0;
            rd_o<='0;
        end
        else begin
            wrEnable_o<=wrEnable_i;
            memToReg_o<=memToReg_i;
            aluResult_o<=aluResult_i;
            rdData_o<=rdData_i;
            rd_o<=rd_i;
        end
    end
    
endmodule