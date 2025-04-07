# Create work library
vlib work

# Compile Verilog files
vlog tpu_axi4_interface.v
vlog tpu_axi4_interface_tb.v

# Start simulation
vsim -c tpu_axi4_interface_tb

# Add waves
add wave -position insertpoint sim:/tpu_axi4_interface_tb/ACLK
add wave -position insertpoint sim:/tpu_axi4_interface_tb/ARESETn
add wave -position insertpoint sim:/tpu_axi4_interface_tb/S_AXI_AWADDR
add wave -position insertpoint sim:/tpu_axi4_interface_tb/S_AXI_AWVALID
add wave -position insertpoint sim:/tpu_axi4_interface_tb/S_AXI_AWREADY
add wave -position insertpoint sim:/tpu_axi4_interface_tb/S_AXI_WDATA
add wave -position insertpoint sim:/tpu_axi4_interface_tb/S_AXI_WVALID
add wave -position insertpoint sim:/tpu_axi4_interface_tb/S_AXI_WREADY
add wave -position insertpoint sim:/tpu_axi4_interface_tb/S_AXI_BVALID
add wave -position insertpoint sim:/tpu_axi4_interface_tb/S_AXI_BREADY
add wave -position insertpoint sim:/tpu_axi4_interface_tb/S_AXI_ARADDR
add wave -position insertpoint sim:/tpu_axi4_interface_tb/S_AXI_ARVALID
add wave -position insertpoint sim:/tpu_axi4_interface_tb/S_AXI_ARREADY
add wave -position insertpoint sim:/tpu_axi4_interface_tb/S_AXI_RDATA
add wave -position insertpoint sim:/tpu_axi4_interface_tb/S_AXI_RVALID
add wave -position insertpoint sim:/tpu_axi4_interface_tb/S_AXI_RREADY
add wave -position insertpoint sim:/tpu_axi4_interface_tb/M_AXI_AWADDR
add wave -position insertpoint sim:/tpu_axi4_interface_tb/M_AXI_AWVALID
add wave -position insertpoint sim:/tpu_axi4_interface_tb/M_AXI_AWREADY
add wave -position insertpoint sim:/tpu_axi4_interface_tb/M_AXI_WDATA
add wave -position insertpoint sim:/tpu_axi4_interface_tb/M_AXI_WVALID
add wave -position insertpoint sim:/tpu_axi4_interface_tb/M_AXI_WREADY
add wave -position insertpoint sim:/tpu_axi4_interface_tb/M_AXI_BVALID
add wave -position insertpoint sim:/tpu_axi4_interface_tb/M_AXI_BREADY
add wave -position insertpoint sim:/tpu_axi4_interface_tb/PSEL
add wave -position insertpoint sim:/tpu_axi4_interface_tb/PENABLE
add wave -position insertpoint sim:/tpu_axi4_interface_tb/PWRITE
add wave -position insertpoint sim:/tpu_axi4_interface_tb/PADDR
add wave -position insertpoint sim:/tpu_axi4_interface_tb/PWDATA
add wave -position insertpoint sim:/tpu_axi4_interface_tb/PRDATA
add wave -position insertpoint sim:/tpu_axi4_interface_tb/PREADY
add wave -position insertpoint sim:/tpu_axi4_interface_tb/tpu_start
add wave -position insertpoint sim:/tpu_axi4_interface_tb/tpu_done
add wave -position insertpoint sim:/tpu_axi4_interface_tb/matrix_size
add wave -position insertpoint sim:/tpu_axi4_interface_tb/operation_type

# Run simulation
run -all

# Save wave file
wave save tpu_axi4_interface_test.wlf

# Quit simulation
quit -f 