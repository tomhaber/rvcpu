cmake_minimum_required(VERSION 3.12)
cmake_policy(SET CMP0074 NEW)
cmake_policy(SET CMP0144 NEW)
project(rvcpu)

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

find_package(fmt)
include(CTest)

add_subdirectory(riscv_iss)

# Create a new executable target that will contain all your sources
add_executable(tb tb/sim_main.cpp)
target_link_libraries(tb PRIVATE riscv_iss)

# Add the Verilated circuit to the target
verilate(tb TRACE
  INCLUDE_DIRS "src" "tb"
  VERILATOR_ARGS --timing --trace-structs
  PREFIX Vtop
  SOURCES src/rvcpu.sv tb/top.sv
)

set(TESTBENCHES
  # cache_tb
  counter_tb
  debounce_tb
  gen_imm_tb
  ram_tb
  regfile_tb
  sync_fifo_tb
  uart_tb
  skid_buf_tb
  sext_tb
  pulse_generator_tb
  prisel_tb
)

foreach(tb ${TESTBENCHES})
  add_executable(${tb}) # tb/cache_sim.cpp)

  # Add the Verilated circuit to the target
  verilate(${tb} TRACE
    INCLUDE_DIRS "src" "tb"
    VERILATOR_ARGS --timing --trace-structs --main
    TOP_MODULE ${tb}
    PREFIX "V${tb}"
    SOURCES src/rvcpu.sv "tb/${tb}.sv"
  )

  add_test(NAME ${tb} COMMAND ${tb})
endforeach(tb ${TESTBENCHES})
