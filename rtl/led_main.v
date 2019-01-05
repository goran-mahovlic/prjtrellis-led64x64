// Simple pipeline for driving an LED panel with 1 bit RGB graphics.
//
// Client should instantiate the `led_main` module and define a
// `painter` module.  `painter` should be a strictly combinatoric
// module that maps <frame, subframe, x, y> into an RGB pixel value.

module led_main
    #(
        parameter USE_RESETN_BUTTON = 1
    ) 
    (
        input CLK,
        input resetn_btn,
        output pll_clk,
        output locked,
        output reset,
        output [2:0] RGB0, RGB1,
        output [4:0] ADDR,
        output BLANK, LATCH, SCLK,
        output [15:0] LED_PANEL
    );

    wire pll_clk;
    wire pll_locked;
    pll_30mhz pll(
        .clk_pin(CLK),
        .locked(pll_locked),
        .pll_clk(pll_clk));
    assign locked = pll_locked;

    wire resetn;
    generate
        if (USE_RESETN_BUTTON) begin
            button_debouncer db(
                .clk(pll_clk),
                .button_pin(resetn_btn),
                .level(resetn));
        end
        else
            assign resetn = 1;
    endgenerate

    reset_logic
    reset_logic_inst
    (
        .resetn(resetn),
        .pll_clk(pll_clk),
        .pll_locked(pll_locked),
        .reset(reset));

    wire [2:0] RGB0, RGB1;
    wire [4:0] ADDR;
    wire BLANK, LATCH, SCLK;
    wire [15:0] LED_PANEL;
    led_driver
    led_driver_inst
    (
        .clk(pll_clk),
        .reset(reset),
        .RGB0(RGB0),
        .RGB1(RGB1),
        .ADDR(ADDR),
        .BLANK(BLANK),
        .LATCH(LATCH),
        .SCLK(SCLK),
        .LED_PANEL(LED_PANEL)
    );

endmodule // led_main
