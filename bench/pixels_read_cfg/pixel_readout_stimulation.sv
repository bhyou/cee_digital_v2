/*************************************************************************
 > Copyright (C) 2022 Sangfor Ltd. All rights reserved.
 > File Name   : pixel_readout_cfg_stimulate.sv
 > Author      : bhyou
 > Mail        : bhyou@foxmail.com 
 > Created Time: Fri 02 Dec 2022 01:14:47 PM CST
 ************************************************************************/
`timescale 1ps/1ps
`define DLY #200
module pixel_read_stimul(
    input  wire              sys_clock    ,
    input  wire              sys_resetn   ,
    // Priority readout
    input  wire              up_valid_i  ,
    input  wire [14:0]       up_addr_i   ,
    input  wire              down_valid_i,
    input  wire [14:0]       down_addr_i ,

    output reg  [180*8-1:0]  timeCnt,
    output reg  [179:0]      STATE  ,
    input  wire [179:0]      ADDREN ,
    input  wire [179:0]      SYNC   
);

    reg [179:0] hit_flag;
    reg         load_state;

    reg [7:0]  time_msg_init [179:0];

    generate
        genvar index;
        for(index = 0; index < 180; index = index + 1) begin
            //always@(negedge SYNC[index], posedge load_state) begin
            //always@(negedge sys_clock, posedge load_state) begin
            always@(edge sys_clock) begin
                if(SYNC[index]) begin
                    STATE[index] <= `DLY 0;
                    timeCnt[index*8+:8] <= `DLY 0;
                end else if(load_state) begin
                    STATE[index] <= hit_flag; 
                    timeCnt[index*8+:8] <= time_msg_init[index];
                end
            end
        end
    endgenerate


    // automatic check block
    reg [1:0] time_err_flag ;
    reg [1:0] addr_err_flag ;
    always @(posedge sys_clock, negedge sys_resetn) begin
        if(up_valid_i) begin
            addr_err_flag[1] <= hit_flag[90+up_addr_i[14:8]] ? 1'b0 : 1'b1;
            time_err_flag[1] <= (time_msg_init[90+up_addr_i[14:8]] == up_addr_i[7:0]) ? 1'b0 : 1'b1;
        end

        if(down_valid_i) begin
            addr_err_flag[0] <= hit_flag[down_addr_i[14:8]] ? 1'b0 : 1'b1;
            time_err_flag[0] <= (time_msg_init[down_addr_i[14:8]] == down_addr_i[7:0]) ? 1'b0 : 1'b1;
        end

    end

    wire timeErrFlag = | time_err_flag;
    wire addrErrFlag = | addr_err_flag;


   // priority test
    initial begin 
        load_state = 1'b0;
        for(int i=0; i<180; i++) begin 
            timeCnt[i*8+:8]  = i + 2;
            hit_flag[i] = 1'b0;
        end
      
        wait(sys_resetn);
        repeat(10) @(posedge sys_clock);

        // traversal all pixels
        traversal_all();
    end

    task traversal_all();
        @(negedge sys_clock);
        load_state = 1'b0;
        for(int i=0; i<180; i++) begin 
            time_msg_init[i]  <= i+4;
            hit_flag[i] <= 1'b1;
        end
        @(posedge sys_clock);
        load_state <= 1'b1;
        @(posedge sys_clock)
        load_state <= 1'b0;
    endtask

endmodule