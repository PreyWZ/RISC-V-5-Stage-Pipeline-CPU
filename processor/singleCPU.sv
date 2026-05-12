
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

    //Decoder
    logic regWrEnable;
    RegNumPath rd,rs,rt;
    logic useImm;
    logic memToReg;
    logic memWrEnable;
    DataPath imm;
    logic isBran;
    func3_type bran_type;



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

	PC pc (
        .clk(clk),
        .rst(rst),
        .addrOut(insnAddr),
        .addrIn(jumpTarget),
        .wrEnable(jumpEnable)
    );

    RegisterFile regfile(
        .clk(clk),
        .rdDataA(rdDataA),
        .rdDataB(rdDataB),
        .rdNumA(rs),
        .rdNumB((memWrEnable)? rd:rt),
        .wrData(wrData),
        .wrNum(rd),
        .wrEnable(regWrEnable)

    );


    Decoder decoder (
        .clk(clk),
        .insn(insn),
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
        .func3(bran_type)
    );

    ALU alu(
        .clk(clk),
        .res(ALUResult),
        .dataA(rdDataA),
        .dataB(useImm? imm : rdDataB),
        .ctr(ctr)
    );


    Branch branch(
        .clk(clk),
        .func3(bran_type),
        .isBran(isBran),
        .pcIns(insnAddr),
        .imm(imm),
        .DataA(rdDataA),
        .DataB(rdDataB),
        .jumpEnable(jumpEnable),
        .jumpTarget(jumpTarget)


    );
    assign dataOut=rdDataB;
    assign dataAddr=ALUResult[DATA_ADDR_WIDTH-1:0];
    assign dataWrEnable=memWrEnable;
    assign wrData=memToReg? dataIn:ALUResult;

endmodule
