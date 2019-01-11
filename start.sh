./converter/cnv.py converter/image.png -p palette.raw -g 2.5 -n 0.6
mv output.mem emard/sprite.mem
mv palette.raw emard/palette.raw
make clean
make
ujprog ulx3s_12f_led64x64.bit
