//-----------------------------------------------------------------------------
// Module: cdc_synchronizer
// Description: 跨时钟域同步器 - 单比特和多比特信号同步
// Author: ICER Skill Package
// Date: 2024
// Version: 1.0
// Features:
//   - 单比特两级同步器
//   - 脉冲同步器
//   - 握手同步器
//   - 支持快到慢和慢到快
//-----------------------------------------------------------------------------

//=============================================================================
// 两级同步器 - 单比特信号
//=============================================================================

module sync_2stage #(
    parameter RESET_VALUE = 0
)(
    input  wire clk,
    input  wire rst_n,
    input  wire data_in,
    output reg  data_out
);

    reg data_d1;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_d1  <= RESET_VALUE;
            data_out <= RESET_VALUE;
        end else begin
            data_d1  <= data_in;
            data_out <= data_d1;
        end
    end

endmodule


//=============================================================================
// 三级同步器 - 高可靠性场景
//=============================================================================

module sync_3stage #(
    parameter RESET_VALUE = 0
)(
    input  wire clk,
    input  wire rst_n,
    input  wire data_in,
    output reg  data_out
);

    reg data_d1, data_d2;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_d1  <= RESET_VALUE;
            data_d2  <= RESET_VALUE;
            data_out <= RESET_VALUE;
        end else begin
            data_d1  <= data_in;
            data_d2  <= data_d1;
            data_out <= data_d2;
        end
    end

endmodule


//=============================================================================
// 脉冲同步器 - 快时钟到慢时钟
//=============================================================================

module pulse_sync (
    input  wire src_clk,
    input  wire src_rst_n,
    input  wire src_pulse,    // 源时钟域脉冲

    input  wire dst_clk,
    input  wire dst_rst_n,
    output wire dst_pulse     // 目标时钟域脉冲
);

    //=========================================================================
    // 源时钟域：脉冲转电平
    //=========================================================================

    reg src_toggle;

    always_ff @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n) begin
            src_toggle <= 1'b0;
        end else if (src_pulse) begin
            src_toggle <= ~src_toggle;
        end
    end

    //=========================================================================
    // 目标时钟域：同步电平，检测边沿
    //=========================================================================

    reg dst_d1, dst_d2, dst_d3;

    always_ff @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin
            dst_d1 <= 1'b0;
            dst_d2 <= 1'b0;
            dst_d3 <= 1'b0;
        end else begin
            dst_d1 <= src_toggle;
            dst_d2 <= dst_d1;
            dst_d3 <= dst_d2;
        end
    end

    // 边沿检测产生脉冲
    assign dst_pulse = dst_d2 ^ dst_d3;

endmodule


//=============================================================================
// 握手同步器 - 多比特数据传输
//=============================================================================

module handshake_sync #(
    parameter DATA_WIDTH = 32
)(
    // 源时钟域
    input  wire                  src_clk,
    input  wire                  src_rst_n,
    input  wire [DATA_WIDTH-1:0] src_data,
    input  wire                  src_valid,
    output wire                  src_ready,

    // 目标时钟域
    input  wire                  dst_clk,
    input  wire                  dst_rst_n,
    output wire [DATA_WIDTH-1:0] dst_data,
    output wire                  dst_valid,
    input  wire                  dst_ready
);

    //=========================================================================
    // 源时钟域逻辑
    //=========================================================================

    reg req_src, ack_src;
    reg [DATA_WIDTH-1:0] data_src;

    // 请求信号
    always_ff @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n) begin
            req_src <= 1'b0;
            data_src <= {DATA_WIDTH{1'b0}};
        end else if (src_valid && src_ready && !req_src) begin
            req_src <= 1'b1;
            data_src <= src_data;
        end else if (ack_src) begin
            req_src <= 1'b0;
        end
    end

    // 准备信号
    assign src_ready = !req_src;

    //=========================================================================
    // 同步请求到目标域
    //=========================================================================

    reg req_dst_d1, req_dst_d2;

    always_ff @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin
            req_dst_d1 <= 1'b0;
            req_dst_d2 <= 1'b0;
        end else begin
            req_dst_d1 <= req_src;
            req_dst_d2 <= req_dst_d1;
        end
    end

    //=========================================================================
    // 目标时钟域逻辑
    //=========================================================================

    reg valid_dst;
    reg [DATA_WIDTH-1:0] data_dst;

    always_ff @(posedge dst_clk or negedge dst_rst_n) begin
        if (!dst_rst_n) begin
            valid_dst <= 1'b0;
            data_dst <= {DATA_WIDTH{1'b0}};
        end else if (req_dst_d2 && !valid_dst) begin
            valid_dst <= 1'b1;
            data_dst <= data_src;  // 数据在请求有效时已经稳定
        end else if (dst_ready && valid_dst) begin
            valid_dst <= 1'b0;
        end
    end

    assign dst_data = data_dst;
    assign dst_valid = valid_dst;

    //=========================================================================
    // 同步应答到源域
    //=========================================================================

    reg ack_src_d1, ack_src_d2;

    always_ff @(posedge src_clk or negedge src_rst_n) begin
        if (!src_rst_n) begin
            ack_src_d1 <= 1'b0;
            ack_src_d2 <= 1'b0;
        end else begin
            ack_src_d1 <= dst_valid && dst_ready;
            ack_src_d2 <= ack_src_d1;
        end
    end

    assign ack_src = ack_src_d2;

endmodule


//=============================================================================
// 复位同步器
//=============================================================================

module reset_sync (
    input  wire clk,
    input  wire async_rst_n,
    output wire sync_rst_n
);

    reg rst_d1, rst_d2;

    always_ff @(posedge clk or negedge async_rst_n) begin
        if (!async_rst_n) begin
            rst_d1 <= 1'b0;
            rst_d2 <= 1'b0;
        end else begin
            rst_d1 <= 1'b1;
            rst_d2 <= rst_d1;
        end
    end

    assign sync_rst_n = rst_d2;

endmodule
