module top
(
    input clk_25mhz,
    input [6:0] btn,
    output [7:0] led,
    output [27:0] gp, gn,
    output wifi_gpio0
);
    // prevent ESP32 firmware from taking control of the board
    // (we don't want it write its "passthru" bitstream)
    assign wifi_gpio0 = 1'b1;
    
    wire pixclk;
    assign pixclk = clk_25mhz;

    wire [6:0] ADDRX;
    wire [4:0] ADDRY;
    wire BLANK, LATCH;
    ledscan
    ledscan_inst
    (
        .clk(pixclk),
        .addrx(ADDRX),
        .addry(ADDRY),
        .latch(LATCH),
        .blank(BLANK)
    );
    
    reg [22:0] blinky;
    always @(posedge pixclk)
    begin
      blinky <= blinky + 1;
    end
    assign led[7] = blinky[22];


    // simple animation counter
    reg [26:0] ANIM;
    always @(posedge pixclk)
    begin
      ANIM <= ANIM + 1;
    end

    // test picture generator
    wire [7:0] CounterX, CounterY;
    wire [4:0] ADDRY0;
    assign ADDRY0 = ADDRY+1;
    assign CounterX = ADDRX + ANIM[26:20];
    assign CounterY = {1'b0,ADDRY0} + ANIM[26:18];
    wire [7:0] W = {8{CounterX[7:0]==CounterY[7:0]}};
    wire [7:0] A = {8{CounterX[7:5]==3'h2 && CounterY[7:5]==3'h2}};
    wire [7:0] red, green, blue;
    assign red = ({CounterX[5:0] & {6{CounterY[4:3]==~CounterX[4:3]}}, 2'b00} | W) & ~A;
    assign green = (CounterX[7:0] & {8{CounterY[6]}} | W) & ~A;
    assign blue = CounterY[7:0] | W | A;

    // same as above but for lower half of the display (32 pixels below)
    wire [7:0] CounterY1;
    assign CounterY1 = {1'b1,ADDRY0} + ANIM[26:18];
    wire [7:0] W1 = {8{CounterX[7:0]==CounterY1[7:0]}};
    wire [7:0] A1 = {8{CounterX[7:5]==3'h2 && CounterY1[7:5]==3'h2}};
    wire [7:0] red1, green1, blue1;
    assign red1 = ({CounterX[5:0] & {6{CounterY1[4:3]==~CounterX[4:3]}}, 2'b00} | W1) & ~A1;
    assign green1 = (CounterX[7:0] & {8{CounterY1[6]}} | W1) & ~A1;
    assign blue1 = CounterY[7:0] | W1 | A1;

    wire [2:0] RGB0, RGB1;
    assign RGB0 = {blue[7], green[7], red[7]};
    assign RGB1 = {blue1[7], green1[7], red1[7]};

    // simple combinatorial logic which also creates some picture
    // assign RGB0 = ADDRX[2:0] == 7 ? 3'b010 : 3'b100; // 3'bBGR
    // assign RGB0 = ADDRX[2:0] == ADDRY[2:0] + ANIM[26:24] ? 3'b010 : 3'b100; // 3'bBGR
    // assign RGB1 = ADDRX[2:0] == ANIM[26:24] ? 3'b011 : 3'b100; // 3'bBGR

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

    // if ULX3S has male header (pins):
    // PMOD is connected with flat cable
    // then swap P and N
    assign gp[17:14] = ogn[17:14];
    assign gn[17:14] = ogp[17:14];
    assign gp[24:21] = ogn[24:21];
    assign gn[24:21] = ogp[24:21];
    
    // if ULX3S has female 90-deg header (holes):
    // PMOD is connected directly to header (align 3.3V/GND)
    // then directly connect P and N
    /*
    assign gp[17:14] = ogp[17:14];
    assign gn[17:14] = ogn[17:14];
    assign gp[24:21] = ogp[24:21];
    assign gn[24:21] = ogn[24:21];
    */
endmodule
