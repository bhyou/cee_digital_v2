/*************************************************************************
 > Copyright (C) 2022 Sangfor Ltd. All rights reserved.
 > File Name   : cee_spi_slave.v
 > Author      : bhyou
 > Mail        : bhyou@foxmail.com 
 > Created Time: Thu 01 Dec 2022 06:08:33 PM CST
 ************************************************************************/
 
module cee_spi_slave(
    input wire         sys_clk_i,
    input wire         sys_rstn_i,
    //SPI Slave Interface
    input  wire        s_spi_csb_,
    input  wire        s_spi_sclk,
    input  wire        s_spi_mosi,
    output wire        s_spi_miso,
    // Regsiter Ouptut
    output wire [7:0]  addr0_out,
    output wire [7:0]  addr1_out,
    output wire [7:0]  addr2_out,

    output wire        cfg_valid,
    output wire [7:0]  cfg_addr,
    output wire [14:0] cfg_data
);

    wire [7:0] addr3_out;
    wire [7:0] addr4_out;
    wire [7:0] addr5_out;

    wire [7:0] ibp_wdata;
    wire [7:0] ibp_rdata;
    wire       ibp_cmd  ;
    wire [6:0] ibp_addr ;
    wire       ibp_valid;
    wire       ibp_ack  ;

    assign cfg_addr  = addr3_out;
    assign cfg_data  = {addr5_out[6:0], addr4_out};
    assign cfg_valid = addr5_out[7];


    spi_slave_inf inst_slave(
        .csb_     (s_spi_csb_),
        .sclk     (s_spi_sclk),
        .mosi     (s_spi_mosi),
        .miso     (s_spi_miso),
        .ibp_cmd  (ibp_cmd  ),
        .ibp_addr (ibp_addr ),
        .ibp_wdata(ibp_wdata),
        .ibp_valid(ibp_valid), 
        .ibp_rdata(ibp_rdata),
        .ibp_ack   (ibp_ack)
    );


    reg_files inst_reg_file(
        .sys_clk_i (sys_clk_i ),
        .sys_rstn_i(sys_rstn_i),
        .ibp_cmd   (ibp_cmd   ),
        .ibp_addr  (ibp_addr  ),
        .ibp_wdata (ibp_wdata ),
        .ibp_valid (ibp_valid ), 
        .ibp_rdata (ibp_rdata ),
        .ibp_ack   (ibp_ack),
        .addr0_out (addr0_out ),
        .addr1_out (addr1_out ),
        .addr2_out (addr2_out ),
        .addr3_out (addr3_out ),
        .addr4_out (addr4_out ),
        .addr5_out (addr5_out )

    );


endmodule