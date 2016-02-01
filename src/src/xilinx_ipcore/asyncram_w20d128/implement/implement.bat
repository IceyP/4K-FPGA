
 
 
 




rem Clean up the results directory
rmdir /S /Q results
mkdir results

rem Synthesize the VHDL Wrapper Files


echo 'Synthesizing example design with XST';
xst -ifn xst.scr
copy asyncram_w20d128_exdes.ngc .\results\


rem Copy the netlist generated by Coregen
echo 'Copying files from the netlist directory to the results directory'
copy ..\..\asyncram_w20d128.ngc results\


rem  Copy the constraints files generated by Coregen
echo 'Copying files from constraints directory to results directory'
copy ..\example_design\asyncram_w20d128_exdes.ucf results\

cd results

echo 'Running ngdbuild'
ngdbuild -p xc6slx16-ftg256-3 asyncram_w20d128_exdes

echo 'Running map'
map asyncram_w20d128_exdes -o mapped.ncd  -pr i

echo 'Running par'
par mapped.ncd routed.ncd

echo 'Running trce'
trce -e 10 routed.ncd mapped.pcf -o routed

echo 'Running design through bitgen'
bitgen -w routed

echo 'Running netgen to create gate level Verilog model'
netgen -ofmt verilog -sim -tm asyncram_w20d128_exdes -pcf mapped.pcf -w -sdf_anno false routed.ncd routed.v
