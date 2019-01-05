# ******* project, board and chip name *******
PROJECT = led64x64
BOARD = ulx3s
FPGA_SIZE = 25

# ******* design files *******
CONSTRAINTS = ulx3s_v20_segpdi.lpf
TOP_MODULE = top
TOP_MODULE_FILE = rtl/lattice/top/top_cable.v
VERILOG_FILES = \
  $(TOP_MODULE_FILE) \
  rtl/button_debouncer.v \
  rtl/led_driver.v \
  rtl/led_main.v \
  rtl/painter.v \
  rtl/pll_30mhz_dummy.v \
  rtl/reset_logic.v
VHDL_TO_VERILOG_FILES = rtl/ddr.v

# synthesis options
YOSYS_OPTIONS = -noccu2

include scripts/ulx3s_trellis.mk
