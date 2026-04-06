//-----------------------------------------------------------------------------
// Module: async_fifo
// Description: 异步 FIFO - 跨时钟域数据传输，支持任意时钟比
// Author: ICER Skill Package
// Date: 2024
// Version: 1.0
// Features:
//   - 支持任意时钟比
//   - 格雷码指针防止亚稳态
//   - 空满标志可靠检测
//   - 参数化深度和数据宽度
//-----------------------------------------------------------------------------

module async_fifo #(
    parameter DATA_WIDTH = 32,
    parameter DEPTH       = 16,
    parameter ADDR_WIDTH  = $clog2(DEPTH)
)(
    // 写时钟域
    input  wire                  wr_clk,
    input  wire                  wr_rst_n,
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output reg                   full,

    // 读时钟域
    input  wire                  rd_clk,
    input  wire                  rd_rst_n,
    input  wire                  rd_en,
    output reg  [DATA_WIDTH-1:0] rd_data,
    output reg                   empty
);

    //=========================================================================
    // 内部信号
    //=========================================================================

    // 格雷码指针（比深度多1位，用于区分空满）
    reg [ADDR_WIDTH:0] wr_ptr_gray;
    reg [ADDR_WIDTH:0] rd_ptr_gray;

    // 二进制指针
    reg [ADDR_WIDTH:0] wr_ptr_bin;
    reg [ADDR_WIDTH:0] rd_ptr_bin;

    // 同步后的指针（用于空满判断）
    reg [ADDR_WIDTH:0] wr_ptr_gray_sync;
    reg [ADDR_WIDTH:0] rd_ptr_gray_sync;

    // 同步寄存器（两级同步器）
    reg [ADDR_WIDTH:0] rd_ptr_gray_d1, rd_ptr_gray_d2;
    reg [ADDR_WIDTH:0] wr_ptr_gray_d1, wr_ptr_gray_d2;

    // 存储器
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    //=========================================================================
    // 格雷码转换函数
    //=========================================================================

    function automatic [ADDR_WIDTH:0] bin_to_gray;
        input [ADDR_WIDTH:0] bin;
        begin
            bin_to_gray = bin ^ (bin >> 1);
        end
    endfunction

    function automatic [ADDR_WIDTH:0] gray_to_bin;
        input [ADDR_WIDTH:0] gray;
        reg [ADDR_WIDTH:0] bin;
        integer i;
        begin
            bin[ADDR_WIDTH] = gray[ADDR_WIDTH];
            for (i = ADDR_WIDTH-1; i >= 0; i = i - 1) begin
                bin[i] = gray[i] ^ bin[i+1];
            end
            gray_to_bin = bin;
        end
    endfunction

    //=========================================================================
    // 写时钟域
    //=========================================================================

    // 写指针递增
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            wr_ptr_bin  <= {ADDR_WIDTH+1{1'b0}};
            wr_ptr_gray <= {ADDR_WIDTH+1{1'b0}};
        end else if (wr_en && !full) begin
            wr_ptr_bin  <= wr_ptr_bin + 1'b1;
            wr_ptr_gray <= bin_to_gray(wr_ptr_bin + 1'b1);
        end
    end

    // 写入数据
    always_ff @(posedge wr_clk) begin
        if (wr_en && !full) begin
            mem[wr_ptr_bin[ADDR_WIDTH-1:0]] <= wr_data;
        end
    end

    // 同步读指针到写时钟域
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            rd_ptr_gray_d1 <= {ADDR_WIDTH+1{1'b0}};
            rd_ptr_gray_d2 <= {ADDR_WIDTH+1{1'b0}};
        end else begin
            rd_ptr_gray_d1 <= rd_ptr_gray;
            rd_ptr_gray_d2 <= rd_ptr_gray_d1;
        end
    end

    assign wr_ptr_gray_sync = rd_ptr_gray_d2;

    // 满标志判断（格雷码最高位和次高位都不同，其余相同）
    always_ff @(posedge wr_clk or negedge wr_rst_n) begin
        if (!wr_rst_n) begin
            full <= 1'b0;
        end else begin
            // 满条件：写指针比读指针多一圈
            full <= (wr_ptr_gray[ADDR_WIDTH] != wr_ptr_gray_sync[ADDR_WIDTH]) &&
                    (wr_ptr_gray[ADDR_WIDTH-1] != wr_ptr_gray_sync[ADDR_WIDTH-1]) &&
                    (wr_ptr_gray[ADDR_WIDTH-2:0] == wr_ptr_gray_sync[ADDR_WIDTH-2:0]);
        end
    end

    //=========================================================================
    // 读时钟域
    //=========================================================================

    // 读指针递增
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            rd_ptr_bin  <= {ADDR_WIDTH+1{1'b0}};
            rd_ptr_gray <= {ADDR_WIDTH+1{1'b0}};
        end else if (rd_en && !empty) begin
            rd_ptr_bin  <= rd_ptr_bin + 1'b1;
            rd_ptr_gray <= bin_to_gray(rd_ptr_bin + 1'b1);
        end
    end

    // 读出数据
    always_ff @(posedge rd_clk) begin
        if (rd_en && !empty) begin
            rd_data <= mem[rd_ptr_bin[ADDR_WIDTH-1:0]];
        end
    end

    // 同步写指针到读时钟域
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            wr_ptr_gray_d1 <= {ADDR_WIDTH+1{1'b0}};
            wr_ptr_gray_d2 <= {ADDR_WIDTH+1{1'b0}};
        end else begin
            wr_ptr_gray_d1 <= wr_ptr_gray;
            wr_ptr_gray_d2 <= wr_ptr_gray_d1;
        end
    end

    assign rd_ptr_gray_sync = wr_ptr_gray_d2;

    // 空标志判断
    always_ff @(posedge rd_clk or negedge rd_rst_n) begin
        if (!rd_rst_n) begin
            empty <= 1'b1;
        end else begin
            // 空条件：写指针等于读指针
            empty <= (rd_ptr_gray == rd_ptr_gray_sync);
        end
    end

    //=========================================================================
    // 断言（用于验证）
    //=========================================================================

    `ifdef FORMAL
        // 不应同时读写满
        assert property(@(posedge wr_clk) disable iff (!wr_rst_n)
            full |-> !(wr_en));
        // 不应同时读空
        assert property(@(posedge rd_clk) disable iff (!rd_rst_n)
            empty |-> !(rd_en));
    `endif

endmodule
