/*************************************************************************
 > Copyright (C) 2022 Sangfor Ltd. All rights reserved.
 > File Name   : spi_serdes.v
 > Author      : bhyou
 > Mail        : bhyou@foxmail.com 
 > Created Time: Fri 04 Nov 2022 08:26:34 PM CST
 ************************************************************************/


// CPOL = 1 : SCLK is high when idle
// CPHA = 1 : 

module spi_serdes #(
    parameter cShiftRegWidth = 16
)(
    input  wire                         sys_clock_i  ,
    input  wire                         sys_reset_i  ,
    input  wire                         start_trans_i,
    input  wire [cShiftRegWidth-1:0]    send_data_i  ,
    output wire [cShiftRegWidth-1:0]    recv_data_o  ,
    output wire                         done_trans_o ,
    output wire                         spi_clk_o    ,
    output reg                          spi_csb_o    ,
    output reg                          spi_sdo_o    ,
    input  wire                         spi_sdi_i     
);
    `define DLY #2
    localparam cShiftFlagInit = 1;

    reg [cShiftRegWidth:0]    shift_flag_r;
    reg [cShiftRegWidth-1:0]  shift_data_r;
    reg                       trans_done_delay;

    always@(posedge sys_clock_i) begin
        spi_csb_o <= `DLY sys_reset_i;
    end

    always@(negedge sys_clock_i) begin
        trans_done_delay <= `DLY shift_flag_r[0];
    end

    // Generate shift flag signal
    always@(posedge sys_clock_i) begin
        if(sys_reset_i) begin
            shift_flag_r <= `DLY cShiftFlagInit;
        end else if( (~shift_flag_r[0]) | start_trans_i)begin  // shifting
            shift_flag_r <= `DLY {shift_flag_r[0], shift_flag_r[cShiftRegWidth:1]};
        end
    end

    //  Simultaneous serialize outgoing data 
    //  & deserialize incoming data. MSB first
    always @(posedge sys_clock_i) begin
        if(~shift_flag_r[0]) begin  //  Shifter is working
            shift_data_r <= `DLY {shift_data_r[cShiftRegWidth-2:0],spi_sdi_i};
        end else if(start_trans_i) begin // IDLE : load parallel input data
            shift_data_r <= `DLY send_data_i;
        end
    end

    // output data in serially @ falling edge of sys_clock_i. MSB first
    always@(negedge sys_clock_i) begin
        if(sys_reset_i) begin
            spi_sdo_o <= `DLY 1'b1;
        end else if(~shift_flag_r[0])begin
            spi_sdo_o <= `DLY shift_data_r[cShiftRegWidth-1];
        end
    end

    assign spi_clk_o = (sys_clock_i | shift_flag_r[0]) | trans_done_delay;
    assign done_trans_o = shift_flag_r[0];
    assign recv_data_o = shift_data_r;


endmodule