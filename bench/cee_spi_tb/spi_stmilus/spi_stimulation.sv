/*************************************************************************
 > Copyright (C) 2022 Sangfor Ltd. All rights reserved.
 > File Name   : spi_stmulus.v
 > Author      : bhyou
 > Mail        : bhyou@foxmail.com 
 > Created Time: Fri 02 Dec 2022 10:32:34 AM CST
 ************************************************************************/
 
module spi_stimulation(
    input  wire        sys_clk_i,
    input  wire        sys_rstn_i,
    input  wire        spi_refclk_i,
    output reg         spi_reset_i,

    output reg [15:0] tx_data,
    output reg        tx_valid,
    input wire [15:0] rx_data ,
    input wire        rx_valid,

    input wire [7:0] addr0_out,
    input wire [7:0] addr1_out,
    input wire [7:0] addr2_out,
    input wire [7:0] addr3_out,
    input wire [7:0] addr4_out,
    input wire [7:0] addr5_out
);

    reg [7:0] rand_val;
    reg [7:0] mem [5:0];

    always@(posedge sys_clk_i, negedge sys_rstn_i) begin
        if(!sys_rstn_i) begin
            rand_val <= 0;
        end else begin
            rand_val <= $random;
            mem[0] <= addr0_out;
            mem[1] <= addr1_out;
            mem[2] <= addr2_out;
            mem[3] <= addr3_out;
            mem[4] <= addr4_out;
            mem[5] <= addr5_out;
        end
    end

    initial begin
        spi_reset_i = 1'b1;
        tx_valid = 0;
        tx_data = 0;
        repeat(3) @(posedge spi_refclk_i);

        spi_write_test(7'h00,rand_val);
        spi_write_test(7'h01,rand_val);
        spi_write_test(7'h02,rand_val);
        spi_write_test(7'h03,rand_val);
        spi_write_test(7'h04,rand_val);
        spi_write_test(7'h05,rand_val);

        spi_read_after_write_test(7'h00,rand_val);
        spi_read_after_write_test(7'h01,rand_val);
        spi_read_after_write_test(7'h02,rand_val);
        spi_read_after_write_test(7'h03,rand_val);
        spi_read_after_write_test(7'h04,rand_val);
        spi_read_after_write_test(7'h05,rand_val);
        repeat(10000)@(posedge sys_clk_i);
        $stop;
    end

    task spi_write_test(input bit[6:0] addr, input bit [7:0] chk_val);
        spi_write_word(addr,chk_val);
        fork
            begin
                wait(chk_val==mem[addr]);        
                $display("@%t Pass: writing %h register is passed.", $realtime, addr);
            end

            begin
                repeat(1000) @(posedge sys_clk_i);
                $display("@%t Error: writing %h register is failed because of time-out.", $realtime, addr);
            end
        join_any
        disable fork;
    endtask

    task spi_read_after_write_test(input bit[6:0] addr, input bit [7:0] chk_val);
        int rdata;

        spi_write_word(addr,chk_val);
        spi_read_word(addr,rdata);
        if(rdata == chk_val) begin
            $display("@%t Passed: spi_read_after_write passed at address %h", $realtime, addr);
        end else begin
            $display("@%t Failed: spi_write %h, spi_read %h, at address %h", $realtime, chk_val, rdata, addr);
        end
    endtask

    task spi_write_word(input bit [6:0] addr, input bit [7:0] data);
        @(negedge spi_refclk_i);
        spi_reset_i <= #2 1'b0;
        tx_valid    <= #2 1'b1;
        tx_data     <= #2 {1'b0,addr,data};
        repeat(16)@(negedge spi_refclk_i);
        spi_reset_i <= 1'b1;
        tx_valid <= 1'b0;
    endtask

    task automatic spi_read_word(input bit [6:0] addr, ref int rdata);
        @(negedge spi_refclk_i);
        spi_reset_i <= #2 1'b0;
        tx_valid    <= #2 1'b1;
        tx_data     <= #2 {1'b1,addr,8'hff};
        repeat(16)@(negedge spi_refclk_i);
        spi_reset_i <= 1'b1;
        tx_valid <= 1'b0;
        @(negedge spi_refclk_i);
        rdata = rx_data[7:0];
    endtask

endmodule