./converter/cnv.py -b converter/image.jpg
mv output.mem emard/sprite.mem
mv palette.raw emard/palette.raw
make clean
make
ujprog ulx3s_12f_led64x64.bit
