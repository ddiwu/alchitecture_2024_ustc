`timescale 1ns / 1ps
// 实验要求
    // 补全模块（阶段三）

module CSR_Regfile(
    input wire clk,
    input wire rst,
    input wire CSR_write_en,
    input wire [11:0] CSR_write_addr,
    input wire [11:0] CSR_read_addr,
    input wire [31:0] CSR_data_write,
    output wire [31:0] CSR_data_read
    );
    
    integer i;
    reg [31:0] regfile[4095:0];

    initial begin
        for (i=0; i<4096; i=i+1)
            regfile[i] = 32'h0;
    end

    always@(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            for (i=0; i<4096; i=i+1)
                regfile[i] <= 32'h0;
        end
        else if(CSR_write_en)
        begin
            regfile[CSR_write_addr] <= CSR_data_write;
        end
    end

    assign CSR_data_read = regfile[CSR_read_addr];

endmodule
