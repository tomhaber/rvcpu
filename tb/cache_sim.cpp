#include <verilated.h>
#include <verilated_vcd_c.h>
#include <memory>
#include "Vtop.h"

vluint64_t main_time = 0;
double sc_time_stamp() {
    return main_time;  // Note does conversion to real, to match SystemC
}

int main(int argc, char** argv, char** env) {
    Verilated::mkdir("logs");

    const auto contextp = std::make_unique<VerilatedContext>();
    contextp->debug(0);
    contextp->randReset(2);
    contextp->traceEverOn(true);
    contextp->commandArgs(argc, argv);

    const auto top = std::make_unique<Vtop>(contextp.get(), "TOP");
    const auto trace = std::make_unique<VerilatedVcdC>();
    top->trace(trace.get(), 99);
    trace->open("cache.vcd");

    while(!contextp->gotFinish()) {
        ++main_time;

        contextp->timeInc(1);
        top->eval();
        if(trace != nullptr)
            trace->dump(main_time);
    }

    top->final();
    trace->close();

    return 0;
}
