# ******* project, board and chip name *******
PROJECT = led64x64
BOARD = ulx3s
FPGA_SIZE = 12
FPGA_PACKAGE = 6bg381c
# config flash: 1:SPI (standard), 4:QSPI (quad)
FLASH_SPI = 4
# chip: is25lp032d is25lp128f s25fl164k
FLASH_CHIP = is25lp128f

# ******* design files *******
CONSTRAINTS = ulx3s_v20_segpdi.lpf
TOP_MODULE = top
TOP_MODULE_FILE = emard/top_cable.v
VERILOG_FILES = \
  $(TOP_MODULE_FILE)
VHDL_FILES = \
  emard/ledscan.vhd \
  emard/flickeram.vhd

include scripts/ulx3s_diamond.mk
