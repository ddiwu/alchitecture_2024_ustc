`timescale 1ns / 1ps
//  功能说明
    //  根据跳转信号，决定执行的下一条指令地址
    //  debug端口用于simulation时批量写入数据，可以忽略
// 输入
    // PC                指令地址（PC + 4, 而非PC）
    // jal_target        jal跳转地址
    // jalr_target       jalr跳转地址
    // br_target         br跳转地址
    // jal               jal == 1时，有jal跳转
    // jalr              jalr == 1时，有jalr跳转
    // br                br == 1时，有br跳转
// 输出
    // NPC               下一条执行的指令地址
// 实验要求  
    // finish
//`define BTB
`define BHT
module NPC_Generator(
    input wire clk,
    input wire [31:0] PC, jal_target, jalr_target, br_target,
    input wire jal, jalr, br,
    input wire flushF, bubbleE,
    input wire [31:0] PC_EX, PC_IF, NPC_EX,
    input wire [2:0] br_type_EX,
    output reg [31:0] NPC,
    output reg br_fail
    );

    // always @ (*)
    // begin
    //     if (br)
    //     begin
    //         NPC = br_target;
    //     end
    //     else if (jalr)// 优先级！！！
    //     begin
    //         NPC = jalr_target;
    //     end
    //     else if (jal)
    //     begin
    //         NPC = jal_target;
    //     end
    //     else 
    //     begin
    //         NPC = PC;
    //     end
    // end
    integer i;

    wire is_br_type;
    assign is_br_type = |br_type_EX;//判断是否有分支

    localparam BTB_SET_WIDTH = 6;
    localparam BTB_SET = 2 ** BTB_SET_WIDTH;
    localparam BTB_TAG_WIDTH = 32 - 2 - BTB_SET_WIDTH;//使用类似cache的直接映射
    localparam BHT_SET_WIDTH = 12;
    localparam BHT_SET = 2 ** BHT_SET_WIDTH;
//    localparam BHT_TAG_WIDTH = 32 - 2 - BHT_SET_WIDTH;

    reg [31:0] br_num;
    reg [31:0] pre_succ_num;

    always @(posedge clk)
    begin
        if (flushF)
        begin
            br_num <= 0;
            pre_succ_num <= 0;
        end
        else if (is_br_type & !bubbleE)//EX阻塞会多算
        begin
            br_num <= br_num + 1;
            if (!br_fail)
                pre_succ_num <= pre_succ_num + 1; 
        end
    end


    // reg [31:0] BTB_PC [0:BTB_SET-1];
    reg [BTB_TAG_WIDTH-1:0] BTB_TAG [0:BTB_SET-1];
    reg [31:0] BTB_TARGET [0:BTB_SET-1];
    reg BTB_VALID [0:BTB_SET-1];
    reg BTB_HIS [0:BTB_SET-1];

    wire BTB_hit;
    assign BTB_hit = BTB_VALID[PC_IF[BTB_SET_WIDTH+1: 2]] & (BTB_TAG[PC_IF[BTB_SET_WIDTH+1: 2]] == PC_IF[31: BTB_SET_WIDTH+2]);//BTB命中在IF阶段判断，因为如果有那么说明一定该PC为br指令

    initial
    begin
        for (i=0; i<BTB_SET; i=i+1)
        begin
            BTB_TAG[i] = 0;
            BTB_TARGET[i] = 0;
            BTB_VALID[i] = 0;
            BTB_HIS[i] = 0;
        end
    end

    //BTB表更新策略，每次EX阶段更新/1bit预测
    always @ (posedge clk)
    begin
        if (flushF)
        begin
            for (i=0; i<BTB_SET; i=i+1)
            begin
                BTB_TAG[i] <= 0;
                BTB_VALID[i] <= 0;
                BTB_TARGET[i] <= 0;
                BTB_HIS[i] <= 0;
            end
        end
        else if (is_br_type)
        begin
            BTB_TAG[PC_EX[BTB_SET_WIDTH+1: 2]] <= PC_EX[31: BTB_SET_WIDTH+2];//字对齐,同时不是TAG_WIDTH
            BTB_HIS[PC_EX[BTB_SET_WIDTH+1: 2]] <= br;
            BTB_TARGET[PC_EX[BTB_SET_WIDTH+1: 2]] <= br_target;
            BTB_VALID[PC_EX[BTB_SET_WIDTH+1: 2]] <= 1;
        end
    end

    reg [1:0] BHT_BIT [0: BHT_SET-1];
    
    wire BHT_hit;
    assign BHT_hit = BHT_BIT[PC_IF[BHT_SET_WIDTH+1: 2]][1];

    initial 
    begin
        for (i = 0; i < BHT_SET; i=i+1)
        begin
            BHT_BIT[i] = 2'b01;
        end
    end

    always @(posedge clk)
    begin
        if (flushF)
        begin
            for (i = 0; i < BHT_SET; i=i+1)
            begin
                BHT_BIT[i] <= 2'b01;
            end
        end
        else if (is_br_type)
        begin
            if (br)
            begin
                if (BHT_BIT[PC_EX[BHT_SET_WIDTH+1: 2]] == 2'b11)
                begin
                    BHT_BIT[PC_EX[BHT_SET_WIDTH+1: 2]] <= 2'b11;
                end
                else BHT_BIT[PC_EX[BHT_SET_WIDTH+1: 2]] <= BHT_BIT[PC_EX[BHT_SET_WIDTH+1: 2]] + 1;
            end
            else 
            begin
                if (BHT_BIT[PC_EX[BHT_SET_WIDTH+1: 2]] == 2'b00)
                    BHT_BIT[PC_EX[BHT_SET_WIDTH+1: 2]] <= 2'b00;
                else BHT_BIT[PC_EX[BHT_SET_WIDTH+1: 2]] <= BHT_BIT[PC_EX[BHT_SET_WIDTH+1: 2]] - 1; 
            end
        end
    end

    // reg br_fail;//分支预测失败
    always @ (*)
    begin
        if (is_br_type)
        begin
            if (br)
            begin
                if (NPC_EX == br_target)
                begin
                    br_fail = 0;
                end
                else
                begin
                    br_fail = 1;
                end
            end
            else
            begin
                if (NPC_EX == PC_EX + 4)
                begin
                    br_fail = 0;
                end
                else 
                begin
                    br_fail = 1;
                end
            end
        end
        else 
        begin
            br_fail = 0;
        end
    end
    // wire [BTB_TAG_WIDTH-1: 0] wbtb_tag;
    // assign wbtb_tag = PC_EX[31: BTB_TAG_WIDTH+2];//字对齐

    always @ (*)
    begin
        if (br_fail)
        begin
            if (br)
            begin
                NPC = br_target;
            end
            else 
            begin
                NPC = PC_EX + 4;
            end
        end
        else if (jalr)
        begin
            NPC = jalr_target;
        end
        else if (jal)
        begin
            NPC = jal_target;
        end
`ifdef BTB
        else if (BTB_hit & BTB_HIS[PC_IF[BTB_SET_WIDTH+1: 2]])
        begin
            NPC = BTB_TARGET[PC_IF[BTB_SET_WIDTH+1: 2]];
        end
`endif
`ifdef BHT
        else if (BHT_hit & BTB_hit)
        begin
            NPC = BTB_TARGET[PC_IF[BTB_SET_WIDTH+1: 2]];
        end
`endif
        else 
        begin
            NPC = PC;
        end
    end
endmodule