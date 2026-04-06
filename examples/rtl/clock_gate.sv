//-----------------------------------------------------------------------------
// Module: clock_gate
// Description: 门控时钟单元 - 低功耗设计核心组件
// Author: ICER Skill Package
// Date: 2024
// Version: 1.0
// Features:
//   - 防止毛刺
//   - 低延迟
//   - 可综合
//   - 支持集成门控单元
//-----------------------------------------------------------------------------

module clock_gate #(
    parameter INTEGRATED_CELL = 0  // 0: RTL实现, 1: 使用集成门控单元
)(
    input  wire clk,
    input  wire enable,
    input  wire test_enable,  // 测试模式使能
    output wire gated_clk
);

    //=========================================================================
    // 方式1: RTL 实现（可综合）
    //=========================================================================

    generate
        if (INTEGRATED_CELL == 0) begin : RTL_IMPL
            // 锁存器：在时钟低电平时锁存使能信号
            reg enable_latch;

            // 综合属性：防止优化掉锁存器
            // synthesis syn_preserve=1

            always_latch begin
                if (~clk) begin
                    enable_latch <= enable | test_enable;
                end
            end

            // 门控输出：仅在时钟上升沿传递
            assign gated_clk = clk & enable_latch;

        end else begin : CELL_IMPL

            //=========================================================================
            // 方式2: 使用集成门控单元（推荐）
            //=========================================================================

            // 集成门控单元库单元
            // 替换为实际库单元名称
            CLK_GATE_CELL u_clk_gate (
                .CLK   (clk),
                .EN    (enable | test_enable),
                .TE    (test_enable),
                .GCLK  (gated_clk)
            );

            // 注：CLK_GATE_CELL 需要在库中定义
            // 典型库单元：TLATNTSCAx, CKLNQDx 等
        end
    endgenerate

endmodule


//=============================================================================
// 门控时钟包装器 - 支持多位数据
//=============================================================================

module clock_gate_wrapper #(
    parameter DATA_WIDTH = 32,
    parameter INTEGRATED_CELL = 0
)(
    input  wire                     clk,
    input  wire                     rst_n,
    input  wire                     enable,
    input  wire [DATA_WIDTH-1:0]    data_in,
    output reg  [DATA_WIDTH-1:0]    data_out
);

    wire gated_clk;

    // 实例化门控时钟
    clock_gate #(
        .INTEGRATED_CELL(INTEGRATED_CELL)
    ) u_clock_gate (
        .clk         (clk),
        .enable      (enable),
        .test_enable (1'b0),
        .gated_clk   (gated_clk)
    );

    // 使用门控时钟的寄存器
    always_ff @(posedge gated_clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= {DATA_WIDTH{1'b0}};
        end else begin
            data_out <= data_in;
        end
    end

endmodule


//=============================================================================
// 门控时钟插入示例 - 综合器自动识别
//=============================================================================

module gated_example (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        enable,
    input  wire [31:0] data_in,
    output wire [31:0] data_out
);

    // 方式1: 使用 enable 条件（综合器自动插入门控）
    // 综合器识别这种模式并自动插入门控时钟
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out <= 32'b0;
        end else if (enable) begin
            data_out <= data_in;
        end
    end

    // 综合属性：指定自动插入门控
    // synthesis preserve_clock_gating

endmodule
