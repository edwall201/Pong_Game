transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+C:/Users/leowe/Downloads/Labs/PC6 {C:/Users/leowe/Downloads/Labs/PC6/vga_controller.v}
vlog -vlog01compat -work work +incdir+C:/Users/leowe/Downloads/Labs/PC6 {C:/Users/leowe/Downloads/Labs/PC6/video_sync_generator.v}
vlog -vlog01compat -work work +incdir+C:/Users/leowe/Downloads/Labs/PC6 {C:/Users/leowe/Downloads/Labs/PC6/pong_renderer.v}

vlog -vlog01compat -work work +incdir+C:/Users/leowe/Downloads/Labs/PC6 {C:/Users/leowe/Downloads/Labs/PC6/pong_renderer_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  pong_renderer_tb

add wave *
view structure
view signals
run -all
