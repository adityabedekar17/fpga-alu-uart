dv/dv_pkg.sv
dv/uart_echo_tb.sv

third_party/alexforencich_uart/rtl/uart_rx.v
third_party/alexforencich_uart/rtl/uart_tx.v

--timing
-j 0
-Wall
--assert
--trace-fst
--trace-structs
--main-top-name "-"
// Run with +verilator+rand+reset+2
--x-assign unique
--x-initial unique
-Werror-IMPLICIT
-Werror-USERERROR
-Werror-LATCH


