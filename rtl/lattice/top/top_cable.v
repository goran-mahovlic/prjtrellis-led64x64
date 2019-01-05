module top (
        input         clk_25mhz,
        output        wifi_gpio0,
        input [6:0]   btn,
        output [7:0]  led,
        output [27:0] gp,gn);
    
    assign wifi_gpio0 = 1'b1;
    wire resetn_btn;
    assign resetn_btn = ~btn[1];
    assign led[0] = resetn_btn;
    
    wire clk_30MHz;
    wire [2:0] RGB0, RGB1;
    wire [4:0] ADDR;
    wire BLANK, LATCH, SCLK;
    led_main main (
        .CLK(clk_25mhz),
        .pll_clk(clk_30MHz),
        .resetn_btn(resetn_btn),
        .RGB0(RGB0),
        .RGB1(RGB1),
        .ADDR(ADDR),
        .BLANK(BLANK),
        .LATCH(LATCH),
        .SCLK(SCLK)
    );

    reg [22:0] counter;
    always @(posedge clk_25mhz)
    begin
      counter <= counter + 1;
    end
    assign led[7] = counter[22];

    wire [27:0] ogp, ogn;
    assign ogp[14] = ADDR[4];
    assign ogn[14] = ADDR[3];
    assign ogp[15] = SCLK;
    assign ogn[15] = ADDR[2];
    assign ogp[16] = LATCH;
    assign ogn[16] = ADDR[1];
    assign ogp[17] = BLANK;
    assign ogn[17] = ADDR[0];
    assign ogp[21] = 1'b0; // X1
    assign ogn[21] = 1'b0; // X0
    assign ogp[22] = RGB1[2]; // B1
    assign ogn[22] = RGB0[2]; // B0
    assign ogp[23] = RGB1[1]; // G1
    assign ogn[23] = RGB0[1]; // G0
    assign ogp[24] = RGB1[0]; // R1
    assign ogn[24] = RGB0[0]; // R0

    assign gp[17:14] = ogn[17:14];
    assign gn[17:14] = ogp[17:14];
    assign gp[24:21] = ogn[24:21];
    assign gn[24:21] = ogp[24:21];

endmodule
