
import BasicTypes::*;
import Types::*;


module CPU(
    input logic clk,    // クロック
    input logic rst,    // リセット
    
    output InsnAddrPath insnAddr,       // 命令メモリへのアドレス出力
    output DataAddrPath dataAddr,       // データバスへのアドレス出力
    output DataPath     dataOut,        // 書き込みデータ出力
                                        // dataAddr で指定したアドレスに対して書き込む値を出力する．
    output logic        dataWrEnable,   // データ書き込み有効

    input  InsnPath     insn,           // 命令メモリからの入力
    input  DataPath     dataIn          // 読み出しデータ入力
                                        // dataAddr で指定したアドレスから読んだ値が入力される．


    
);
    //forward
    logic [1:0] forwardA,forwardB;
    DataPath fwd_DataA,fwd_DataB;

    //Decoder
    logic regWrEnable;
    RegNumPath rd,rs,rt;
    logic useImm;
    logic memToReg;
    logic memWrEnable;
    DataPath imm;
    logic isBran;
    logic isJal;
    logic isJalr;
    br_func3_type bran_type;



    //ALU
    DataPath ALUResult;
    CtrALU ctr;

    //RegFile 
    DataPath wrData;
    DataPath rdDataA;
    DataPath rdDataB;



    //Branch
    logic jumpEnable;
    InsnAddrPath jumpTarget;
    DataPath linkAddr;

    //IF_ID
    InsnPath if_id_insn;
    InsnAddrPath if_id_pc;

    //ID_EX
    logic id_ex_regWrEnable,id_ex_memWrEnable,id_ex_memToReg;
    logic id_ex_useImm,id_ex_isBran,id_ex_isJal,id_ex_isJalr;
    CtrALU id_ex_ctr;
    br_func3_type id_ex_func3;

    DataPath id_ex_rdDataA,id_ex_rdDataB;
    RegNumPath id_ex_rd,id_ex_rs,id_ex_rt;
    DataPath id_ex_imm;
    InsnAddrPath id_ex_pc;


    //EX_MEM
    logic ex_mem_regWrEnable;
    logic ex_mem_memWrEnable;
    logic ex_mem_memToReg;
    DataPath ex_mem_aluResult;
    RegNumPath ex_mem_rd;
    DataPath ex_mem_memData;



    //MEM_WB
    logic mem_wb_wrEnable;
    logic mem_wb_memToReg;
    DataPath mem_wb_aluResult;
    DataPath mem_wb_rdData;
    RegNumPath mem_wb_rd;

    logic stall;
    logic flush_if_id;
    logic flush_id_ex;

    always_comb begin
        stall=1'b0;
        if (id_ex_memToReg && id_ex_rd!='0) begin
            if (id_ex_rd == rs)begin
                stall=1'b1;
            end
            if (id_ex_rd==rt)begin
                stall=1'b1;
            end
        end
        
    end

    assign flush_if_id=jumpEnable;
    assign flush_id_ex=jumpEnable || stall;


//IF
	PC pc (
        .clk(clk),
        .rst(rst),
        .addrOut(insnAddr),
        .addrIn(jumpTarget),
        .wrEnable(jumpEnable),
        .stall(stall)
    );
    

    IF_IDRegister if_id(
        .clk(clk),
        .rst(rst),
        .pc_i(insnAddr),
        .insn_i(insn),
        .pc_o(if_id_pc),
        .insn_o(if_id_insn),
        .stall(stall),
        .flush(flush_if_id)

    );

//ID
    RegisterFile regfile(
        .clk(clk),
        .rdDataA(rdDataA),
        .rdDataB(rdDataB),
        .rdNumA(rs),
        .rdNumB(rt),
        .wrData(wrData),
        .wrNum(mem_wb_rd),
        .wrEnable(mem_wb_wrEnable)

    );


    Decoder decoder (
        .clk(clk),
        .insn(if_id_insn),
        .rd(rd),
        .rs(rs),
        .rt(rt),
        .imm(imm),
        .ctr(ctr),
        .regWrEnable(regWrEnable),
        .memWrEnable(memWrEnable),
        .memToReg(memToReg),
        .useImm(useImm),
        .isBran(isBran),
        .isJal(isJal),
        .isJalr(isJalr),
        .br_func3(bran_type)
    );

    ID_EXRegister id_ex(
        .clk(clk),
        .rst(rst),
        .regWrEnable_i(regWrEnable),
        .memWrEnable_i(memWrEnable),
        .memToReg_i(memToReg),
        .isBran_i(isBran),
        .isJal_i(isJal),
        .isJalr_i(isJalr),
        .br_func3_i(bran_type),
        .ctr_i(ctr),
        .useImm_i(useImm),
        .rdDataA_i(rdDataA),
        .rdDataB_i(rdDataB),
        .rd_i(rd),
        .rs_i(rs),
        .rt_i(rt),
        .flush(flush_id_ex),
        .imm_i(imm),
        .pc_i(if_id_pc),
        .regWrEnable_o(id_ex_regWrEnable),
        .memWrEnable_o(id_ex_memWrEnable),
        .memToReg_o(id_ex_memToReg),
        .isBran_o(id_ex_isBran),
        .isJal_o(id_ex_isJal),
        .isJalr_o(id_ex_isJalr),
        .br_func3_o(id_ex_func3),
        .ctr_o(id_ex_ctr),
        .useImm_o(id_ex_useImm),
        .rdDataA_o(id_ex_rdDataA),
        .rdDataB_o(id_ex_rdDataB),
        .rd_o(id_ex_rd), 
        .rs_o(id_ex_rs),
        .rt_o(id_ex_rt),
        .imm_o(id_ex_imm),
        .pc_o(id_ex_pc)
    );

//EX

    always_comb begin
        forwardA=2'b00;
        if ( mem_wb_wrEnable && mem_wb_rd!='0 && mem_wb_rd==id_ex_rs )begin
            forwardA=2'b01;
        end
        if(ex_mem_regWrEnable && ex_mem_rd!='0 && ex_mem_rd==id_ex_rs ) begin
            forwardA=2'b10;
        end
    end

    always_comb begin
        forwardB=2'b00;
        if ( mem_wb_wrEnable && mem_wb_rd!='0 && mem_wb_rd==id_ex_rt )begin
            forwardB=2'b01;
        end
        if(ex_mem_regWrEnable && ex_mem_rd!='0 && ex_mem_rd==id_ex_rt ) begin
            forwardB=2'b10;
        end
    end

    always_comb begin
        case(forwardA)
            2'b01:fwd_DataA=wrData;
            2'b10:fwd_DataA=ex_mem_aluResult;
            default:fwd_DataA=id_ex_rdDataA;
        endcase

        case(forwardB)
            2'b01:fwd_DataB=wrData;
            2'b10:fwd_DataB=ex_mem_aluResult;
            default:fwd_DataB=id_ex_rdDataB;
        endcase
    end

    ALU alu(
        .clk(clk),
        .res(ALUResult),
        .dataA(fwd_DataA),
        .dataB(id_ex_useImm? id_ex_imm : fwd_DataB),
        .ctr(id_ex_ctr)
    );



    Branch branch(
        .clk(clk),
        .br_func3(id_ex_func3),
        .isBran(id_ex_isBran),
        .isJal(id_ex_isJal),
        .isJalr(id_ex_isJalr),
        .pcIns(id_ex_pc),
        .imm(id_ex_imm),
        .dataA(fwd_DataA),
        .dataB(fwd_DataB),
        .jumpEnable(jumpEnable),
        .jumpTarget(jumpTarget),
        .linkAddr(linkAddr)
    );

    DataPath ex_result;
    assign ex_result=(id_ex_isJal || id_ex_isJalr)? linkAddr : ALUResult;

    EX_MEMRegister ex_mem(
        .clk(clk),
        .rst(rst),
        .regWrEnable_i(id_ex_regWrEnable),
        .memWrEnable_i(id_ex_memWrEnable),
        .memToReg_i(id_ex_memToReg),
        .aluResult_i(ex_result),
        .memData_i(fwd_DataB),
        .rd_i(id_ex_rd),
        .regWrEnable_o(ex_mem_regWrEnable),
        .memWrEnable_o(ex_mem_memWrEnable),
        .memToReg_o(ex_mem_memToReg),
        .aluResult_o(ex_mem_aluResult),
        .memData_o(ex_mem_memData),
        .rd_o(ex_mem_rd)
    );

//MEM




    MEM_WBRegister mem_wb(
        .clk(clk),
        .rst(rst),
        .wrEnable_i(ex_mem_regWrEnable),
        .memToReg_i(ex_mem_memToReg),
        .aluResult_i(ex_mem_aluResult),
        .rdData_i(dataIn),
        .rd_i(ex_mem_rd),
        .wrEnable_o(mem_wb_wrEnable),
        .memToReg_o(mem_wb_memToReg),
        .aluResult_o(mem_wb_aluResult),
        .rdData_o(mem_wb_rdData),
        .rd_o(mem_wb_rd)

    );
//WB


    assign dataOut=ex_mem_memData;
    assign dataAddr=ex_mem_aluResult[DATA_ADDR_WIDTH-1:0];
    assign dataWrEnable=ex_mem_memWrEnable;
    assign wrData=mem_wb_memToReg? mem_wb_rdData:mem_wb_aluResult;

endmodule
