transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components/cache_one_cycle {/home/anwesag2/just-put-whatever/mp4/hdl/components/cache_one_cycle/line_adapter.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components/cache_one_cycle {/home/anwesag2/just-put-whatever/mp4/hdl/components/cache_one_cycle/data_array.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components/cache_one_cycle {/home/anwesag2/just-put-whatever/mp4/hdl/components/cache_one_cycle/cache_datapath.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components/cache_one_cycle {/home/anwesag2/just-put-whatever/mp4/hdl/components/cache_one_cycle/cache_control.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components/cache_one_cycle {/home/anwesag2/just-put-whatever/mp4/hdl/components/cache_one_cycle/array.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components {/home/anwesag2/just-put-whatever/mp4/hdl/components/rv32i_types.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components {/home/anwesag2/just-put-whatever/mp4/hdl/components/register.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components {/home/anwesag2/just-put-whatever/mp4/hdl/components/regfile.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components {/home/anwesag2/just-put-whatever/mp4/hdl/components/pc_reg.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components {/home/anwesag2/just-put-whatever/mp4/hdl/components/mux.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components {/home/anwesag2/just-put-whatever/mp4/hdl/components/cacheline_adapter.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components {/home/anwesag2/just-put-whatever/mp4/hdl/components/arbiter.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components/cache_one_cycle {/home/anwesag2/just-put-whatever/mp4/hdl/components/cache_one_cycle/cache.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components {/home/anwesag2/just-put-whatever/mp4/hdl/components/hdu.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components {/home/anwesag2/just-put-whatever/mp4/hdl/components/fu.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components {/home/anwesag2/just-put-whatever/mp4/hdl/components/cmp.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/components {/home/anwesag2/just-put-whatever/mp4/hdl/components/alu.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/stages {/home/anwesag2/just-put-whatever/mp4/hdl/stages/stage_registers.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/stages {/home/anwesag2/just-put-whatever/mp4/hdl/stages/control_rom.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/stages {/home/anwesag2/just-put-whatever/mp4/hdl/stages/WB.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/stages {/home/anwesag2/just-put-whatever/mp4/hdl/stages/MEM.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/stages {/home/anwesag2/just-put-whatever/mp4/hdl/stages/IF.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/stages {/home/anwesag2/just-put-whatever/mp4/hdl/stages/ID.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl/stages {/home/anwesag2/just-put-whatever/mp4/hdl/stages/EX.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl {/home/anwesag2/just-put-whatever/mp4/hdl/datapath.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hdl {/home/anwesag2/just-put-whatever/mp4/hdl/mp4.sv}

vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hvl {/home/anwesag2/just-put-whatever/mp4/hvl/magic_dual_port.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hvl {/home/anwesag2/just-put-whatever/mp4/hvl/param_memory.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hvl {/home/anwesag2/just-put-whatever/mp4/hvl/rvfi_itf.sv}
vlog -vlog01compat -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hvl {/home/anwesag2/just-put-whatever/mp4/hvl/rvfimon.v}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hvl {/home/anwesag2/just-put-whatever/mp4/hvl/shadow_memory.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hvl {/home/anwesag2/just-put-whatever/mp4/hvl/source_tb.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hvl {/home/anwesag2/just-put-whatever/mp4/hvl/tb_itf.sv}
vlog -sv -work work +incdir+/home/anwesag2/just-put-whatever/mp4/hvl {/home/anwesag2/just-put-whatever/mp4/hvl/top.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L arriaii_hssi_ver -L arriaii_pcie_hip_ver -L arriaii_ver -L rtl_work -L work -voptargs="+acc"  mp4_tb

add wave *
view structure
view signals
run -all
