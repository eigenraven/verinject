
#include <stdio.h>
#include "xparameters.h"
#include "platform.h"
#include "xil_printf.h"
#include "xtime_l.h"
#include "verinject_axi_driver.h"

volatile verinject_axi_interface* vj;

const uint64_t RUNS_ARRAY[] = {
#include "c_runs.inc"
};

#define RUNS_ARRAY_LEN (sizeof(RUNS_ARRAY)/sizeof(uint64_t))

void membarrier() {
	asm volatile("" ::: "memory");
}

void reset_vj() {
	vj->running_flags = VERINJECT_AXI_RUNNING_NOT;
	vj->cycle_number = 0;
	vj->stop_cycle_number = 256;
	vj->log_position = 0;
	vj->trace_position = 0;
	for(int i=0; i<1024; i++) {
		vj->trace_data[i] = ~(uint64_t)0;
	}
	membarrier();
}

void print_vj_log() {
	uint32_t end_pos = vj->log_position;
	uint32_t maxqwords = vj->log_qword_count;
	if(end_pos > maxqwords) {
		end_pos = maxqwords;
	}
	for(uint32_t i = 0; i < end_pos; i++) {
		uint64_t entry = vj->log_data[i];
		uint32_t cycle = (uint32_t)(entry >> 32ULL) - 1; // adjust for "pipelined" logging
		uint32_t xorsum = (uint32_t)(entry & 0xFFFFFFFFULL);
		xil_printf("Sum mismatch at cycle %15d: xor(%08x)\n", cycle, xorsum);
	}
}

int main()
{
    init_platform();
    XTime init_time;
    XTime_GetTime(&init_time);
    vj = (verinject_axi_interface*)XPAR_VERINJECT_AXI_DRIVER_0_BASEADDR;

    xil_printf("Verinject AXI address: %08x\n", (u32)vj);
    xil_printf("Log qwords: %d\nTrace qwords: %d\n", vj->log_qword_count, vj->trace_qword_count);

    print("Initializing platform...\n");
    reset_vj();
    XTime postinit_time;
    XTime_GetTime(&postinit_time);
    xil_printf("Init time: %d\n", (int)(postinit_time - init_time));

    XTime t_all_start, t_all_end;
    XTime_GetTime(&t_all_start);

    for(int runid=0; runid < RUNS_ARRAY_LEN; runid++) {
    	xil_printf("run%d\n", runid);

    	vj->running_flags = VERINJECT_AXI_RUNNING_NOT;
    	vj->cycle_number = 0;
    	vj->log_position = 0;
    	vj->trace_position = 0;
    	uint64_t tdata = RUNS_ARRAY[runid];
		vj->trace_data[0] = tdata;
		vj->trace_data[1] = ~(uint64_t)0;
		xil_printf("verinject: at cycle %15d injected into bit %10d\n", (int)(tdata >> 32), (int)(tdata & 0xFFFFFFFF));
		membarrier();

		vj->running_flags = VERINJECT_AXI_RUNNING_RUN;
		while(vj->running_flags&VERINJECT_AXI_RUNNING_RUN) {}
		membarrier();

		print_vj_log();
    }

    membarrier();
    XTime_GetTime(&t_all_end);
    u64 all_cycles = t_all_end - t_all_start;
    printf("Finished all runs in %llu cycles", all_cycles);

    cleanup_platform();
    return 0;
}
