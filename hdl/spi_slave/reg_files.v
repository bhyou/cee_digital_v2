/*************************************************************************
 > Copyright (C) 2022 Sangfor Ltd. All rights reserved.
 > File Name   : reg_files.v
 > Author      : 
 > Mail        :  
 > Created Time: Thu 01 Dec 2022 12:49:20 PM CST
 ************************************************************************/
 
module reg_files(
    input wire         sys_clk_i,
    input wire         sys_rstn_i,

    // internal bus signal
    input  wire        ibp_cmd   ,
    input  wire [6:0]  ibp_addr  ,
    input  wire [7:0]  ibp_wdata ,
    input  wire        ibp_valid ,
    output wire        ibp_ack   , 
    output wire [7:0]  ibp_rdata ,

    // Regsiter Ouptut
    output wire [7:0]  addr0_out,
    output wire [7:0]  addr1_out,
    output wire [7:0]  addr2_out,
    output wire [7:0]  addr3_out,
    output wire [7:0]  addr4_out,
    output wire [7:0]  addr5_out
);

    parameter cReadCmd  = 1'b1;
    parameter cWriteCmd = 1'b0;
    parameter cMemDepth = 6;

    localparam cAddr0Init = 8'h00;
    localparam cAddr1Init = 8'h01;
    localparam cAddr2Init = 8'hEF;
    localparam cAddr3Init = 8'h00;
    localparam cAddr4Init = 8'hFF;
    localparam cAddr5Init = 8'hAF;


    reg [2:0] ibp_valid_debounce;
    reg [7:0] mem [cMemDepth-1:0];

    // SPI Read feedback
    assign ibp_rdata =  mem[ibp_addr];

    // Register file output
    assign addr0_out = mem[0];
    assign addr1_out = mem[1];
    assign addr2_out = mem[2];
    assign addr3_out = mem[3];
    assign addr4_out = mem[4];
    assign addr5_out = mem[5];

    // signal synchronized, from sclk domain data to sys_clk_i domain
    reg  ibp_ack_r;
    always @(posedge sys_clk_i, negedge sys_rstn_i) begin
        if(!sys_rstn_i) begin
            ibp_valid_debounce <= 0;
            ibp_ack_r <= 1'b1;
        end else begin
            if(ibp_valid_debounce[2]) begin
                ibp_ack_r <= 1'b1;
            end else begin
                ibp_ack_r <= 1'b0;  
            end
            ibp_valid_debounce <= {ibp_valid_debounce[1:0],ibp_valid};
        end
    end

    assign ibp_ack = ibp_ack_r;

    always @(posedge sys_clk_i, negedge sys_rstn_i) begin
        if(!sys_rstn_i) begin
            mem[0] <= cAddr0Init;
            mem[1] <= cAddr1Init;
            mem[2] <= cAddr2Init;
            mem[3] <= cAddr3Init;
            mem[4] <= cAddr4Init;
            mem[5] <= cAddr5Init;
        end else begin
            if(ibp_valid_debounce[2] & (ibp_cmd == cWriteCmd) & (~ibp_ack)) begin
                mem[ibp_addr] <= ibp_wdata;
            end
        end
    end




endmodule