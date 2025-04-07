# Create work library
vlib work

# Compile all files
vlog Memristor_Infra_Booth_4bit.v
vlog Memristor_Infra_Multiplier_4bit.v
vlog Memristor_Infra_Multiplier_4bit_AXI4.v
vlog Memristor_Infra_Multiplier_4bit_AXI4_tb.v

# Start simulation
vsim Memristor_Infra_Multiplier_4bit_AXI4_tb

# Add waves
add wave -position insertpoint sim:/Memristor_Infra_Multiplier_4bit_AXI4_tb/*

# Run simulation
run -all 