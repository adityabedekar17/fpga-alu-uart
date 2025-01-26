
yosys -import
read_verilog synth/build/rtl.sv2v.v synth/icestorm_icebreaker/icebreaker.v

synth_ice40 -top icebreaker

write_json synth/icestorm_icebreaker/build/synth.json
write_verilog synth/icestorm_icebreaker/build/synth.v 
write_verilog -noexpr -noattr -simple-lhs synth/icestorm_icebreaker/build/synth.v

