gui_open_window Wave
gui_sg_create pll60_group
gui_list_add_group -id Wave.1 {pll60_group}
gui_sg_addsignal -group pll60_group {pll60_tb.test_phase}
gui_set_radix -radix {ascii} -signals {pll60_tb.test_phase}
gui_sg_addsignal -group pll60_group {{Input_clocks}} -divider
gui_sg_addsignal -group pll60_group {pll60_tb.CLK_IN1}
gui_sg_addsignal -group pll60_group {{Output_clocks}} -divider
gui_sg_addsignal -group pll60_group {pll60_tb.dut.clk}
gui_list_expand -id Wave.1 pll60_tb.dut.clk
gui_sg_addsignal -group pll60_group {{Status_control}} -divider
gui_sg_addsignal -group pll60_group {pll60_tb.RESET}
gui_sg_addsignal -group pll60_group {pll60_tb.LOCKED}
gui_sg_addsignal -group pll60_group {{Counters}} -divider
gui_sg_addsignal -group pll60_group {pll60_tb.COUNT}
gui_sg_addsignal -group pll60_group {pll60_tb.dut.counter}
gui_list_expand -id Wave.1 pll60_tb.dut.counter
gui_zoom -window Wave.1 -full
