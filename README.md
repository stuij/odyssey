### what

tbd

### make

The target is the ULX3S FPGA board is based upon the Lattice ECP5 FPGA. It's a
prototype board with lots of features in a small form factor. For more
info, see https://ulx3s.github.io.

Currently the only tested toolchain for this project is Trellis (or rather the
tools associated with Trellis).

Have the Trellis tools installed, and run `make` in this directory to create a
bitstream. Run fujprog to install it over USB:

  fujprog ulx3s_85f_odyssey.bit
