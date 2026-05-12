
package Types;

// 基本的な定数や型の定義
import BasicTypes::*;

// ここより下に，各人の定義を追加してください

parameter REG_FILE_SIZE=32;
parameter REG_NUM_WIDTH=5;
typedef logic [REG_NUM_WIDTH-1:0] RegNumPath;


parameter CTR_ALU_WIDTH = 4;
typedef enum logic [CTR_ALU_WIDTH-1:0] {
    ALU_ADD = 4'b0000,
    ALU_SUB = 4'b0001,
    ALU_AND = 4'b0010,
    ALU_OR  = 4'b0011,
    ALU_XOR = 4'b0100,
    ALU_SLT = 4'b0101,
    ALU_LUI = 4'b0110
} CtrALU;

parameter FUNC3_WIDTH=3;
typedef enum logic [FUNC3_WIDTH-1:0] { 
    
    FUNC3_ADD_ADDI = 3'b000,
    FUNC3_SLT_SLTI = 3'b010,
    FUNC3_XOR      = 3'b100,
    FUNC3_OR       = 3'b110,
    FUNC3_AND      = 3'b111
} func3_type;

parameter OP_WIDTH=7;
typedef enum logic [OP_WIDTH-1:0]{
    OP_R    = 7'b0110011,
    OP_I    = 7'b0010011,
    OP_LUI  = 7'b0110111,
    OP_SW   = 7'b0100011,
    OP_B    = 7'b1100011,
    OP_LW   = 7'b0000011,
    OP_JALR = 7'b1100111,
    OP_JAL  = 7'b1101111

} opcode_type;


parameter FUNC7_WIDTH = 7;
typedef enum logic [FUNC7_WIDTH-1:0] {
    FUNC7_ADD = 7'b0000000,
    FUNC7_SUB = 7'b0100000
} func7_type;


parameter BR_FUNC3_WIDTH=3;
typedef enum  logic [BR_FUNC3_WIDTH-1:0] { 
    BR_BEQ=3'b000,
    BR_BNE=3'b001,
    BR_BLT=3'b100,
    BR_BGE=3'b101
} br_func3_type;


endpackage
