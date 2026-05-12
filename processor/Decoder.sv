import BasicTypes::*;
import Types::*;

module Decoder(
    input InsnPath insn,
    input logic clk,

    output RegNumPath rd,
    output RegNumPath rs,
    output RegNumPath rt,
    output DataPath imm,
    output CtrALU ctr,
    output logic regWrEnable,
    output logic memWrEnable,
    output logic memToReg,
    output logic useImm,
    output logic isBran,
    output logic isJal,
    output logic isJalr,
    output br_func3_type br_func3

);
    opcode_type opcode;
    assign opcode = opcode_type'(insn[6:0]);

    func7_type func7;
    assign func7 = func7_type'(insn[31:25]);

    func3_type func3;
    assign func3 = func3_type'(insn[14:12]);

    assign br_func3 = br_func3_type'(insn[14:12]);


    always_comb  begin
            rd=insn[11:7];
            rs=insn[19:15];
            rt=insn[24:20];
            regWrEnable = 1'b0;
            memWrEnable = 1'b0;
            memToReg = 1'b0;
            useImm = 1'b0;
            imm = '0;
            ctr=ALU_ADD;
            isBran=1'b0;
            isJal=1'b0;
            isJalr=1'b0;
        case (opcode)
            OP_R : begin
                imm=32'b0;
                regWrEnable=1'b1;

                case(func7)
                    FUNC7_ADD: begin

                        case(func3)
                            FUNC3_ADD_ADDI : ctr = ALU_ADD;
                            FUNC3_SLT_SLTI : ctr = ALU_SLT;
                            FUNC3_OR       : ctr = ALU_OR;
                            FUNC3_XOR      : ctr = ALU_XOR;
                            FUNC3_AND      : ctr = ALU_AND;
                            default        : ctr = ALU_ADD;
                        endcase
                        
                    end
                    FUNC7_SUB : ctr = ALU_SUB;
                    default   : ctr = ALU_ADD;
                endcase

            end

            OP_I : begin
                imm={{20{insn[31]}},insn[31:20]};
                regWrEnable=1'b1;
                useImm=1'b1;
                case(func3)
                    FUNC3_ADD_ADDI : ctr = ALU_ADD;
                    FUNC3_SLT_SLTI : ctr = ALU_SLT;
                    FUNC3_OR       : ctr = ALU_OR;
                    FUNC3_XOR      : ctr = ALU_XOR;
                    FUNC3_AND      : ctr = ALU_AND;
                    default        : ctr = ALU_ADD;
                endcase
            end

            OP_LUI : begin
                imm={insn[31:12], 12'b0};
                regWrEnable=1'b1;
                useImm=1'b1;
                ctr=ALU_LUI;
            end

            OP_LW : begin
                imm={{20{insn[31]}},insn[31:20]};
                regWrEnable=1'b1;
                useImm=1'b1;
                ctr=ALU_ADD;
                memToReg=1'b1;
            end

            OP_SW : begin
                imm={{20{insn[31]}},insn[31:25],insn[11:7]};
                useImm=1'b1;
                ctr=ALU_ADD;
                memWrEnable=1'b1;
            end

            OP_B : begin 
                imm={{19{insn[31]}},insn[31],insn[7],insn[30:25],insn[11:8],1'b0};
                isBran=1'b1;
            end

            OP_JAL : begin
                imm = {{11{insn[31]}}, insn[31], insn[19:12], insn[20], insn[30:21], 1'b0};
                regWrEnable=1'b1;
                isJal=1'b1;
            end

            OP_JALR : begin 
                imm = {{20{insn[31]}}, insn[31:20]};
                regWrEnable=1'b1;
                useImm=1'b1;
                isJalr=1'b1;
            end

            default : begin
            end

        endcase
    end
endmodule