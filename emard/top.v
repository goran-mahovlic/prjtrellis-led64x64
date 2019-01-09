module top
(
    input clk_25mhz,
    input [6:0] btn,
    output [7:0] led,
    output [27:0] gp, gn,
    output wifi_gpio0
);
    //  0: PMOD straight male header to flat cable
    // 90: PMOD 90-deg female header
    parameter PMOD_J1 = 0;
    parameter PMOD_J2 = 90;

    // prevent ESP32 firmware from taking control of the board
    // (we don't want it write its "passthru" bitstream)
    assign wifi_gpio0 = 1'b1;
    
    wire pixclk;
    assign pixclk = clk_25mhz;

    // simple animation counter
    parameter anim_bits = 26;
    reg [anim_bits-1:0] ANIM;
    always @(posedge pixclk)
    begin
      ANIM <= ANIM + 1;
    end

    // simple combinatorial logic which also creates some picture
    // assign RGB0 = ADDRX[2:0] == 7 ? 3'b010 : 3'b100; // 3'bBGR
    // assign RGB0 = ADDRX[2:0] == ADDRY[2:0] + ANIM[26:24] ? 3'b010 : 3'b100; // 3'bBGR
    // assign RGB1 = ADDRX[2:0] == ANIM[26:24] ? 3'b011 : 3'b100; // 3'bBGR

    // test picture generator
    wire [7:0] CounterX, CounterY;
    wire [4:0] ADDRY0;
    assign ADDRY0 = ADDRY+1;
    assign CounterX = ADDRX + ANIM[anim_bits-1:anim_bits-7];
    assign CounterY = {1'b0,ADDRY0} + ANIM[anim_bits-1:anim_bits-9];
    wire [7:0] W = {8{CounterX[7:0]==CounterY[7:0]}};
    wire [7:0] A = {8{CounterX[7:5]==3'h2 && CounterY[7:5]==3'h2}};
    reg [7:0] red, green, blue;
    always @(posedge pixclk) red <= ({CounterX[5:0] & {6{CounterY[4:3]==~CounterX[4:3]}}, 2'b00} | W) & ~A;
    always @(posedge pixclk) green = (CounterX[7:0] & {8{CounterY[6]}} | W) & ~A;
    always @(posedge pixclk) blue = CounterY[7:0] | W | A;

    // same as above but for lower half of the display (32 pixels below)
    wire [7:0] CounterY1;
    assign CounterY1 = {1'b1,ADDRY0} + ANIM[anim_bits-1:anim_bits-9];
    wire [7:0] W1 = {8{CounterX[7:0]==CounterY1[7:0]}};
    wire [7:0] A1 = {8{CounterX[7:5]==3'h2 && CounterY1[7:5]==3'h2}};
    reg [7:0] red1, green1, blue1;
    always @(posedge pixclk) red1 = ({CounterX[5:0] & {6{CounterY1[4:3]==~CounterX[4:3]}}, 2'b00} | W1) & ~A1;
    always @(posedge pixclk) green1 = (CounterX[7:0] & {8{CounterY1[6]}} | W1) & ~A1;
    always @(posedge pixclk) blue1 = CounterY[7:0] | W1 | A1;

    wire [2:0] RGB0, RGB1;

    // for 3bpp mode
    // assign RGB0 = {blue[7], green[7], red[7]};
    // assign RGB1 = {blue1[7], green1[7], red1[7]};

    wire [6:0] ADDRX;
    wire [4:0] ADDRY;
    wire BLANK, LATCH;
    ledscan
    ledscan_inst
    (
        .clk(pixclk),
        .r0(red),
        .g0(green),
        .b0(blue),
        .r1(red1),
        .g1(green1),
        .b1(blue1),
        .rgb0(RGB0),
        .rgb1(RGB1),
        .addrx(ADDRX),
        .addry(ADDRY),
        .latch(LATCH),
        .blank(BLANK)
    );
    
/* ----------------------------
       Custom video generator
   ----------------------------*/

  //  wire [23:0] sprite_rgb;

    wire [10:0] sprite_x;
    wire [10:0] sprite_y;

    sprite_rom upper_sprite(
        .clk(pixclk),
        .addr({ sprite_y[5:0], sprite_x[5:0] }),
        .data_out(RGB0));

    sprite_rom lower_sprite(
        .clk(pixclk),
        .addr({ sprite_y[5:0], sprite_x[5:0] }),
        .data_out(RGB1));

/* Custom video generator */

    reg [22:0] blinky;
    always @(posedge pixclk)
    begin
      blinky <= blinky + 1;
    end
    assign led[7] = blinky[22];

    // output pins mapping to ULX3S board    
    wire [27:0] ogp, ogn;
    assign ogp[14] = ADDRY[4];
    assign ogn[14] = ADDRY[3];
    assign ogp[15] = pixclk; // SCLK display clock
    assign ogn[15] = ADDRY[2];
    assign ogp[16] = LATCH;
    assign ogn[16] = ADDRY[1];
    assign ogp[17] = BLANK;
    assign ogn[17] = ADDRY[0];
    assign ogp[21] = 1'b0; // X1
    assign ogn[21] = 1'b0; // X0
    assign ogp[22] = RGB1[2]; // B1
    assign ogn[22] = RGB0[2]; // B0
    assign ogp[23] = RGB1[1]; // G1
    assign ogn[23] = RGB0[1]; // G0
    assign ogp[24] = RGB1[0]; // R1
    assign ogn[24] = RGB0[0]; // R0

    generate
      if(PMOD_J1 == 90)
      // if ULX3S has 90-deg female header (holes):
      // PMOD is connected directly to header (align 3.3V/GND)
      // directly connect P and N
      begin : J1_90deg
        // J1 connector
        assign gp[3:0] = ogp[17:14];
        assign gn[3:0] = ogn[17:14];
        assign gp[10:7] = ogp[24:21];
        assign gn[10:7] = ogn[24:21];
      end
    endgenerate

    generate
      if(PMOD_J1 == 0)
      // if ULX3S has straight male header (pins):
      // PMOD is connected with flat cable (align 3.3V/GND)
      // swap P and N
      begin : J1_flat_cable
        // J1 connector
        assign gp[3:0] = ogn[17:14];
        assign gn[3:0] = ogp[17:14];
        assign gp[10:7] = ogn[24:21];
        assign gn[10:7] = ogp[24:21];
      end
    endgenerate

    generate
      if(PMOD_J2 == 90)
      // if ULX3S has 90-deg female header (holes):
      // PMOD is connected directly to header (align 3.3V/GND)
      // directly connect P and N
      begin : J2_90deg
        // J2 connector
        assign gp[17:14] = ogp[17:14];
        assign gn[17:14] = ogn[17:14];
        assign gp[24:21] = ogp[24:21];
        assign gn[24:21] = ogn[24:21];
      end
    endgenerate

    generate
      if(PMOD_J2 == 0)
      // if ULX3S has straight male header (pins):
      // PMOD is connected with flat cable (align 3.3V/GND)
      // swap P and N
      begin : J2_flat_cable
        // J2 connector
        assign gp[17:14] = ogn[17:14];
        assign gn[17:14] = ogp[17:14];
        assign gp[24:21] = ogn[24:21];
        assign gn[24:21] = ogp[24:21];
      end
    endgenerate
    
endmodule
