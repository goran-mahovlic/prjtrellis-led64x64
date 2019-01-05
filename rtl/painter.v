module painter(
        input        clk,
        input        reset,
        input [12:0] frame,
        input  [7:0] subframe,
        input  [5:0] x,
        input  [5:0] y,
        output [2:0] rgb);

    wire [12:0] xx = {~3'd0, x} - frame[10:2];
    wire red = 320 <= xx && xx < 448;
    wire grn = 160 <= xx && xx < 288;
    wire blu =   0 <= xx && xx < 128;

    //            BLUE GREEN RED
    assign rgb = {blu, grn, red};

endmodule // painter
