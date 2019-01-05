module pll_30mhz (
        input clk_pin,
        output locked,
        output pll_clk);
        
    wire clk_200MHz;
    clk_25_200
    clk_25_200_inst
    (
      .CLKI(clk_pin),
      .CLKOP(clk_200MHz)
    );
    
    wire clk_60MHz;
    
    clk_200_60_30
    clk_200_60_30_inst
    (
      .CLKI(clk_200MHz),
      .CLKOP(clk_60MHz),
      .CLKOS(pll_clk), // 30 MHz
      .LOCKED(locked)
    );

endmodule // pll30mhz
