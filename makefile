# ******* project, board and chip name *******
PROJECT = led64x64
BOARD = ulx3s
FPGA_SIZE = 12

# ******* design files *******
CONSTRAINTS = ulx3s_v20_segpdi.lpf
TOP_MODULE = top
TOP_MODULE_FILE = emard/top.v
VERILOG_FILES = \
  $(TOP_MODULE_FILE) \
  emard/sprite_rom.v
VHDL_TO_VERILOG_FILES = \
  emard/ledscan.v

# synthesis options
YOSYS_OPTIONS = -noccu2

include scripts/ulx3s_trellis.mk
