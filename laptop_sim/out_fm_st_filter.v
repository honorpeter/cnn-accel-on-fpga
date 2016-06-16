/*
* Created           : cheng liu
* Date              : 2016-06-014
*
* Description:
* 
* This module specifies the invalid data element of in_fm tile and replaces them with zero. 
* 
*
* Instance example

*/

// synposys translate_off
`timescale 1ns/100ps
// synposys translate_on

module out_fm_st_filter #(

    parameter AW = 16,
    parameter CW = 16,
    parameter DW = 32,
    parameter N = 32,
    parameter M = 32,
    parameter R = 64,
    parameter C = 32,
    parameter tile_offset = 2,
    parameter Tn = 16,
    parameter Tm = 16,
    parameter Tr = 64,
    parameter Tc = 16,
    parameter S = 1,
    parameter K = 3

)(
    input                              fifo_push_tmp,
    input                    [DW-1: 0] data_to_fifo_tmp,
    
    output                             fifo_push,
    output                   [DW-1: 0] data_to_fifo,

    input                    [CW-1: 0] tile_base_n,
    input                    [CW-1: 0] tile_base_row,
    input                    [CW-1: 0] tile_base_col,

    input                              clk,
    input                              rst
);

    localparam row_step = ((Tr + S - K)/S) * S;
    localparam col_step = ((Tc + S - K)/S) * S;
    localparam R_step = ((R + S - K)/S) * S;
    localparam C_step = ((C + S - K)/S) * S;
    
    wire                               is_data_legal;
    reg                      [DW-1: 0] data_to_fifo_reg;
    reg                                fifo_push_reg;
    wire                               done;
    reg                                done_reg;

    wire                     [CW-1: 0] tc;
    wire                     [CW-1: 0] tr;
    wire                     [CW-1: 0] tn;

    assign data_to_fifo = data_to_fifo_reg;
    assign fifo_push = is_data_legal ? fifo_push_reg : 0;

    always@(posedge clk or posedge rst) begin
        if(rst == 1'b1) begin
            fifo_push_reg <= 0;
            data_to_fifo_reg <= 0;
            done_reg <= 0;
        end
        else begin
            fifo_push_reg <= fifo_push_tmp;
            data_to_fifo_reg <= data_to_fifo_tmp;
            done_reg <= done;
        end
    end

    nest3_counter #(

        .CW (CW),
        .n0_max (Tc),
        .n1_max (Tr),
        .n2_max (Tn)

    ) nest3_counter_inst (
        .ena (fifo_push_tmp),
        .clean (done_reg),

        .cnt0 (tc),
        .cnt1 (tr),
        .cnt2 (tn),

        .done (done),

        .clk (clk),
        .rst (rst)
    );

    assign is_data_legal = (tile_base_n + tn < N) &&
                           (tile_base_row + tr < R_step) &&
                           (tile_base_col + tc < C) && (tc < col_step) && (tr < row_step);
                           //(tile_base_col + tc < C_step) && (tc < col_step) && (tr < row_step);


endmodule