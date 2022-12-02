##########################################################################
# Copyright (C) 2022 Sangfor Ltd. All rights reserved.
# File Name   : Makefile
# Author      : bhyou
# mail        : bhyou@foxmail.com
# Created Time: Fri 02 Dec 2022 10:53:39 AM CST
#########################################################################


comp_args += -override_timescale=1ps/1ps
comp_args += -full64 -sverilog +v2k -debug_pp


vlog_spi_src += ../hdl/spi_slave/cee_spi_slave_top.v
vlog_spi_src += ../hdl/spi_slave/reg_files.v
vlog_spi_src += ../hdl/spi_slave/spi_slave.v

vlog_spi_tb += ../bench/cee_spi_tb/cee_spi_tb.v
vlog_spi_tb += ../bench/cee_spi_tb/spi_stmilus/spi_stimulation.sv
vlog_spi_tb += ../bench/cee_spi_tb/spi_master/spi_master.v


vlog_pixel_src += ../hdl/pixels_read_cfg/pixel_rd_cfg.v
vlog_pixel_src += ../hdl/pixels_read_cfg/pixel_cfg/pixel_cfg_decode.v
vlog_pixel_src += ../hdl/pixels_read_cfg/Priority/PriorityCell.v
vlog_pixel_src += ../hdl/pixels_read_cfg/Priority/PriorityEncodeTree.v

vlog_pixel_tb += ../bench/pixels_read_cfg/pixel_cfg_stimulation.sv
vlog_pixel_tb += ../bench/pixels_read_cfg/pixel_readout_stimulation.sv
vlog_pixel_tb += ../bench/pixels_read_cfg/pixels_read_cfg_tb.sv




spi_com:
	vcs $(comp_args) $(vlog_spi_src) $(vlog_spi_tb)	-top spi_bench

pix_com:
	vcs $(comp_args) $(vlog_pixel_src) $(vlog_pixel_tb)	-top pixels_read_cfg_tb
	
clean:
	rm -fr csrc  DVEfiles  inter.vpd  simv  simv.daidir  ucli.key  vc_hdrs.h 
