/*************************************************************************
 > Copyright (C) 2022 Sangfor Ltd. All rights reserved.
 > File Name   : spi_slave.v
 > Author      : 
 > Mail        :  
 > Created Time: Thu 01 Dec 2022 09:57:16 AM CST
 ************************************************************************/
 
// ibp_* : internal bus protocol
// * Read operation:
//    ibp_cmd and ibp_addr is valid when ibp_valid is set. At the same time, 
//                 ______         ______        ___
//  spi_clk  : ___/      \_______/      \______/
//                      | here the ibp_rdata must be already (before the falling edge of sclk). 
//                      __________
//  ibp_rdata: ________/data ready\_______
//                  _____________________
//  ibp_cmd  : ____/  Read      \_________
//                  ____________________
//  ibp_addr : ____/ addr       \_______
//

// * Write operation:
//                 ____      _______         ___
//  spi_clk  : ___/    \____/x-clock\_______/
//                 ______________________________
//  ibp_cmd  : ___/  Read                   \_________
//                _______________________________
//  ibp_addr : ___/ addr                    \_______
//                                           __________
//  ibp_wdata: _____________________________/data ready\_______
//                                           ____________
//  ibp_valid: _____________________________/            \_______

//                                                       ____________
//  ibp_ack  : _________________________________________/            \_______
// 
//  ibp_ack is driven by another clock domain. 

// SPI timing :
// data change  at falling edge on output direction
// data sample at rising edge on input direction

//            _____                                                  ______
//  spi_csb  :     \________________________________________________/
//                 ____      ____      ____      ____      ____      _______
//  spi_clk  : ___/    \____/    \____/    \____/    \____/    \____/    
//                          _________           _________            _______
//  spi_mosi : ___X________/ new bit \_new_bit_/ new bit \_new bit__/new bit
//                      _________           _________            _______
//  spi_miso : ___X____/ new bit \_new_bit_/ new bit \_new bit__/new bit

module spi_slave_inf(
    input  wire       csb_,
    input  wire       sclk,
    input  wire       mosi,
    output reg        miso,
    //
    output wire        ibp_cmd   ,
    output wire [6:0]  ibp_addr  ,
    output wire [7:0]  ibp_wdata ,
    output wire        ibp_valid ,
    input  wire        ibp_ack   , 
    input  wire [7:0]  ibp_rdata
);

    parameter cShiftFlagInit  = 1;
    parameter cShiftRegWidth  = 8;
    localparam cShiftFlagWidth = cShiftRegWidth * 2  + 1;

    parameter cReadCmd        = 1'h1;

    reg [cShiftRegWidth-1:0]  shift_reg;
    reg [cShiftFlagWidth-1:0] shift_flag;

    reg                       spi_cmd_code;
    reg [6:0]                 spi_cmd_addr;
    reg [7:0]                 spi_cmd_wdata;
    reg                       spi_cmd_valid;
    wire                       read_cmd ;

    // Simultaneous serialize outgoing data & deserialize incoming data. MSB first
    always@(posedge sclk) begin
        if(shift_flag[cShiftRegWidth] & read_cmd) begin
            shift_reg <= {ibp_rdata[cShiftRegWidth-2:0],mosi};
        end else if(~shift_flag[cShiftFlagWidth-1])begin
            shift_reg <= {shift_reg[cShiftRegWidth-1:0],mosi};
        end
    end

    // output data in serially @ falling edge of sys_clock_i. MSB first
 `ifdef SpiDaisyChain   
    always@(negedge sclk) begin
        if(read_cmd & shift_flag[cShiftRegWidth]) begin
            miso <= ibp_rdata[cShiftRegWidth-1];
        end else begin 
            miso <= shift_reg[cShiftRegWidth-1];
        end
    end
`else
    always@(negedge sclk, posedge csb_) begin
        if(csb_) begin
            miso <= 1'b1;
        end else if(read_cmd & shift_flag[cShiftRegWidth]) begin
            miso <= ibp_rdata[cShiftRegWidth-1];
        end else begin 
            miso <= shift_reg[cShiftRegWidth-1];
        end
    end
`endif
    
    // Generate shift flag signal
    always@(posedge sclk, posedge csb_) begin
        if(csb_) begin
            shift_flag <= cShiftFlagInit;
        end else if(~shift_flag[cShiftFlagWidth-1]) begin
            shift_flag <= {shift_flag[cShiftFlagWidth-2:0],shift_flag[cShiftFlagWidth-1]};
        end
    end

    // internal bus protocol command and address output
    always@(posedge sclk, posedge ibp_ack) begin
        if(ibp_ack) begin
            spi_cmd_code <= 0;
            spi_cmd_addr <= 0;
        end else begin
            if(shift_flag[cShiftRegWidth-1]) begin
                spi_cmd_code <= shift_reg[6];
                spi_cmd_addr <= {shift_reg[5:0], mosi};
            end
        end
    end

    // internal bus protocol data and valid output
    always@(posedge sclk, posedge ibp_ack) begin
        if(ibp_ack) begin
            spi_cmd_valid <= 1'b0;
            spi_cmd_wdata <= 8'h0;
        end else begin
            if(shift_flag[cShiftRegWidth*2-1]) begin
                spi_cmd_valid <= shift_flag[cShiftRegWidth*2-1];
                spi_cmd_wdata <= {shift_reg[6:0], mosi};
            end
        end
    end

    assign read_cmd  = (spi_cmd_code==cReadCmd) ? 1'b1: 1'b0;
    assign ibp_cmd   = spi_cmd_code;
    assign ibp_addr  = spi_cmd_addr;
    assign ibp_wdata = spi_cmd_wdata;
    assign ibp_valid = spi_cmd_valid;
endmodule