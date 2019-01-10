module sprite_rom(
  input clk,
  input [5:0] addrx,
  input [4:0] addry,
  output [23:0] data0,
  output [23:0] data1
);

  reg [4:0] store[0:4095];
  wire [23:0] palette[0:15];

assign palette[0] = 24'h000000;
assign palette[1] = 24'h808080;
assign palette[2] = 24'hc0c0c0;
assign palette[3] = 24'hffffff;
assign palette[4] = 24'h800000;
assign palette[5] = 24'hff0000;
assign palette[6] = 24'h808000;
assign palette[7] = 24'hffff00;
assign palette[8] = 24'h008000;
assign palette[9] = 24'h00ff00;
assign palette[10] = 24'h008080;
assign palette[11] = 24'h00ffff;
assign palette[12] = 24'h000080;
assign palette[13] = 24'h0000ff;
assign palette[14] = 24'h800080;
assign palette[15] = 24'hff00ff;

  initial
  begin
		$readmemh("emard/sprite.mem", store);
  end

  wire [23:0] data0, data1;
  
  wire [5:0] ax;
  wire [4:0] ay;
  
  assign ax = addrx;
  assign ay = addry + 1; // test with -1
  
  reg [3:0] pixel0, pixel1;
  
  always @(posedge clk) pixel0 <= store[ {1'b0, ay, ax } ];
  always @(posedge clk) pixel1 <= store[ {1'b1, ay, ax } ];
  
  assign data0 = palette[pixel0];
  assign data1 = palette[pixel1];

endmodule
