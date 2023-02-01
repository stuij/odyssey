# ******* project, board and chip name *******
PROJECT = odyssey
BOARD = ulx3s
# 12 25 45 85
FPGA_SIZE = 85

# ******* design files *******
CONSTRAINTS = ulx3s_v20_segpdi.lpf
TOP_MODULE = odyssey_top
PREFIX = verilog
TOP_MODULE_FILE = $(PREFIX)/$(TOP_MODULE).v

VERILOG_FILES = \
$(TOP_MODULE_FILE) \
$(PREFIX)/ecp5pll.sv \
$(PREFIX)/emhard-vga.v \
$(PREFIX)/lcd_video.v \
$(PREFIX)/odyssey.v \
$(PREFIX)/ps2kbd.v \

# *.vhd those files will be converted to *.v files with vhdl2vl (warning overwriting/deleting)
VHDL_FILES = \

YOSYS_OPTIONS = -abc9
NEXTPNR_OPTIONS = --timing-allow-fail

SCRIPTS = scripts
include $(SCRIPTS)/trellis_path.mk
include $(SCRIPTS)/trellis_main.mk
