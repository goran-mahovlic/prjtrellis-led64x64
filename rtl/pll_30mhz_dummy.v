module pll_30mhz (
        input clk_pin,
        output locked,
        output pll_clk);
    
    assign pll_clk = clk_pin;
    assign locked = 1'b1;
endmodule // pll30mhz
