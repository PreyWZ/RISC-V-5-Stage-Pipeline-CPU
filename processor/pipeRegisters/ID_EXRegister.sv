import BasicTypes::*;
import Types::*;
module ID_EXRegister (
    input logic clk,
    input logic rst,

    input logic flush,
    input logic regWrEnable_i,
    input logic memWrEnable_i,
    input logic memToReg_i,
    input logic useImm_i,
    input logic isBran_i,
    input logic isJal_i,
    input logic isJalr_i,
    input br_func3_type br_func3_i,
    input CtrALU ctr_i,

    input DataPath rdDataA_i,
    input DataPath rdDataB_i,
    input RegNumPath rd_i,
    input RegNumPath rs_i,
    input RegNumPath rt_i,
    input DataPath imm_i,
    input InsnAddrPath pc_i,
    
    
    output logic regWrEnable_o,
    output logic memWrEnable_o,
    output logic memToReg_o,
    output logic isBran_o,
    output logic isJal_o,
    output logic isJalr_o,
    output br_func3_type br_func3_o,
    output CtrALU ctr_o,
    output logic useImm_o,

    output DataPath rdDataA_o,
    output DataPath rdDataB_o,
    output RegNumPath rd_o,
    output RegNumPath rs_o,
    output RegNumPath rt_o,
    output DataPath imm_o,
    output InsnAddrPath pc_o

    

);
    always_ff @( posedge clk or posedge rst  ) begin
        if (rst || flush) begin
            regWrEnable_o<='0;
            memWrEnable_o<='0;
            memToReg_o<='0;
            isBran_o<='0;
            isJal_o<='0;
            isJalr_o<='0;
            br_func3_o<=BR_BEQ;
            ctr_o<=ALU_ADD;
            useImm_o<='0;
            rdDataA_o<='0;
            rdDataB_o<='0;
            rd_o<='0;
            rs_o<='0;
            rt_o<='0;
            imm_o<=32'b0;
            pc_o<='0;

        end
        else begin
            regWrEnable_o<=regWrEnable_i;
            memWrEnable_o<=memWrEnable_i;
            memToReg_o<=memToReg_i;
            isBran_o<=isBran_i;
            isJal_o<=isJal_i;
            isJalr_o<=isJalr_i;
            br_func3_o<=br_func3_i;
            ctr_o<=ctr_i;
            useImm_o<=useImm_i;
            rdDataA_o<=rdDataA_i;
            rdDataB_o<=rdDataB_i;
            rd_o<=rd_i;
            rs_o<=rs_i;
            rt_o<=rt_i;
            imm_o<=imm_i;
            pc_o<=pc_i;
        end
    end
endmodule