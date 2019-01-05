module led_driver (
        input         clk,
        input         reset,
        output [2:0] RGB0, RGB1,
        output [4:0] ADDR,
        output BLANK, LATCH, SCLK,
        output [15:0] LED_PANEL);

    // State machine.
    localparam S_START   = 6'b000001;
    localparam S_SHIFT0  = 6'b000010;
    localparam S_SHIFT   = 6'b000100;
    localparam S_SHIFTN  = 6'b001000;
    localparam S_BLANK   = 6'b010000;
    localparam S_UNBLANK = 6'b100000;

    // Route outputs to LED panel with registers as needed.
    reg   [2:0] led_rgb0;
    reg   [2:0] led_rgb1;
    reg   [4:0] led_addr;
    wire        led_blank;
    wire        led_latch;
    wire        led_sclk;
    wire        P1A1, P1A2, P1A3, P1A4, P1A7, P1A8, P1A9, P1A10;
    wire        P1B1, P1B2, P1B3, P1B4, P1B7, P1B8, P1B9, P1B10;

    assign RGB0 = led_rgb0;
    assign RGB1 = led_rgb1;
    assign ADDR = led_rgb0;
    assign BLANK = led_blank;
    assign LATCH = led_latch;
    assign SCLK = sclk;    

    // This panel has swapped red and blue wires.
    // assign {P1A3, P1A2, P1A1}              = led_rgb0;
    // assign {P1A9, P1A8, P1A7}              = led_rgb1;
    assign {P1A1, P1A2, P1A3}              = led_rgb0;
    assign {P1A7, P1A8, P1A9}              = led_rgb1;
    assign {P1B10, P1B4, P1B3, P1B2, P1B1} = led_addr;
    assign P1B7                            = led_blank;
    assign P1B8                            = led_latch;
    assign P1B9                            = led_sclk;
    assign {P1A4, P1A10}                   = 0;
    assign LED_PANEL = {P1B10, P1B9, P1B8, P1B7,  P1B4, P1B3, P1B2, P1B1,
                        P1A10, P1A9, P1A8, P1A7,  P1A4, P1A3, P1A2, P1A1};

    wire  [4:0] addr;
    wire  [7:0] subframe;
    wire [12:0] frame;
    wire  [5:0] x;
    wire  [5:0] y0, y1;
    wire  [2:0] rgb0, rgb1;

    reg  [31:0] cnt;
    reg   [4:0] state;
    reg   [1:0] blank;
    reg   [1:0] latch;
    reg   [1:0] sclk;
    reg   [4:0] state;

    assign {frame, subframe, addr, x} = cnt;
    assign y0 = {1'b0, addr};
    assign y1 = {1'b1, addr};

    always @(posedge clk)
        if (reset) begin
            led_rgb0              <= 0;
            led_rgb1              <= 0;
            led_addr              <= 0;
            cnt                   <= 0;
            blank                 <= 2'b11;
            latch                 <= 2'b00;
            sclk                  <= 2'b10;
            state                 <= S_START;
        end
        else
            case (state)

                S_START:          // Exit reset; start shifting column data.
                    begin
                        blank     <= 2'b11; // blank until first row is latched
                        state     <= S_SHIFT;
                    end

                S_SHIFT0:         // Shift first column.
                    begin
                        led_rgb0  <= rgb0;
                        led_rgb1  <= rgb1;
                        cnt       <= cnt + 1;
                        blank     <= 2'b00;
                        sclk      <= 2'b10;
                        state     <= S_SHIFT;
                    end

                S_SHIFT:          // Shift a column.
                    begin
                        led_rgb0  <= rgb0;
                        led_rgb1  <= rgb1;
                        cnt       <= cnt + 1;
                        sclk      <= 2'b10;
                        if (x == 62) // next column will be the last.
                            state <= S_SHIFTN;
                    end

                S_SHIFTN:         // Shift the last column; start BLANK.
                    begin
                        blank     <= 2'b01;
                        led_rgb0  <= rgb0;
                        led_rgb1  <= rgb1;
                        state     <= S_BLANK;
                    end

                S_BLANK:          // Drain shift register; pulse LATCH.
                    begin
                        blank     <= 2'b11;
                        latch     <= 2'b11;
                        sclk      <= 2'b00;
                        state     <= S_UNBLANK;
                    end

                S_UNBLANK:        // End BLANK; start next row.
                    begin
                        led_addr  <= addr;
                        cnt       <= cnt + 1;
                        blank     <= 2'b10;
                        latch     <= 2'b00;
                        state     <= S_SHIFT0;
                    end

            endcase

    painter paint0(
        .clk(clk),
        .reset(reset),
        .frame(frame),
        .subframe(subframe),
        .x(x[5:0]),
        .y(y0),
        .rgb(rgb0));

    painter paint1(
        .clk(clk),
        .reset(reset),
        .frame(frame),
        .subframe(subframe),
        .x(x[5:0]),
        .y(y1),
        .rgb(rgb1));

    ddr led_blank_ddr(
        .clk(clk),
        .data(blank),
        .ddr_pin(led_blank));

    ddr led_latch_ddr(
        .clk(clk),
        .data(latch),
        .ddr_pin(led_latch));

    ddr led_sclk_ddr(
        .clk(clk),
        .data(sclk),
        .ddr_pin(led_sclk));

endmodule // led_driver
