//-----------------------------------------------------------------------------
// Module: tb_top
// Description: UVM 测试平台顶层
// Author: ICER Skill Package
// Date: 2024
// Version: 1.0
//-----------------------------------------------------------------------------

`timescale 1ns/1ps
`include "uvm_macros.svh"

module tb_top;

    import uvm_pkg::*;

    //=========================================================================
    // 时钟和复位
    //=========================================================================

    parameter CLK_PERIOD = 10;  // 100MHz

    logic clk;
    logic rst_n;

    // 时钟生成
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // 复位生成
    initial begin
        rst_n = 0;
        #(CLK_PERIOD * 5);
        rst_n = 1;
    end

    //=========================================================================
    // DUT 实例化
    //=========================================================================

    // 替换为实际 DUT
    dut_if dut_vif(clk, rst_n);

    dut #(
        .DATA_WIDTH(32),
        .DEPTH(16)
    ) u_dut (
        .clk    (dut_vif.clk),
        .rst_n  (dut_vif.rst_n),
        // 添加其他端口连接
        .wr_en  (dut_vif.wr_en),
        .wr_data(dut_vif.wr_data),
        .full   (dut_vif.full),
        .rd_en  (dut_vif.rd_en),
        .rd_data(dut_vif.rd_data),
        .empty  (dut_vif.empty)
    );

    //=========================================================================
    // UVM 配置
    //=========================================================================

    initial begin
        // 设置接口
        uvm_config_db#(virtual dut_if)::set(null, "*", "vif", dut_vif);

        // 运行测试
        run_test();
    end

    //=========================================================================
    // 波形转储
    //=========================================================================

    initial begin
        if ($test$plusargs("WAVE")) begin
            $fsdbDumpfile("wave.fsdb");
            $fsdbDumpvars(0, tb_top);
        end
    end

    //=========================================================================
    // 超时控制
    //=========================================================================

    initial begin
        #100000000;  // 100ms 超时
        `uvm_fatal("TIMEOUT", "Simulation timeout")
    end

endmodule


//=============================================================================
// DUT 接口定义
//=============================================================================

interface dut_if (
    input logic clk,
    input logic rst_n
);

    // 信号定义
    logic        wr_en;
    logic [31:0] wr_data;
    logic        full;
    logic        rd_en;
    logic [31:0] rd_data;
    logic        empty;

    // 时钟块
    clocking cb @(posedge clk);
        output wr_en, wr_data, rd_en;
        input  full, rd_data, empty;
    endclocking

    // 同步任务
    task wait_cycles(int n);
        repeat(n) @(posedge clk);
    endtask

endinterface
