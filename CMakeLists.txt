cmake_minimum_required(VERSION 3.12)
cmake_policy(SET CMP0074 NEW)
cmake_policy(SET CMP0144 NEW)
project(rvcpu)

find_package(verilator HINTS $ENV{VERILATOR_ROOT} ${VERILATOR_ROOT})
if (NOT verilator_FOUND)
  message(FATAL_ERROR "Verilator was not found. Either install it, or set the VERILATOR_ROOT environment variable")
endif()

find_package(fmt)

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

add_executable(cache_sim tb/cache_sim.cpp)

# Add the Verilated circuit to the target
verilate(cache_sim TRACE
  INCLUDE_DIRS "src" "tb"
  VERILATOR_ARGS --timing --trace-structs
  PREFIX Vtop
  SOURCES tb/cache_tb.sv
)

