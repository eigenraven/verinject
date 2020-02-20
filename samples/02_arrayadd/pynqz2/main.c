// For use in a Xilinx Vitis 2019.2 Project
#include <stdio.h>
#include "xparameters.h"
#include "platform.h"
#include "xil_printf.h"
#include "xtime_l.h"
#include "verinject_axi_driver.h"

volatile verinject_axi_interface* vj;

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
	membarrier();
	uint32_t end_pos = vj->log_position;
	uint32_t maxqwords = vj->log_qword_count;
	xil_printf("Finished at cycle = %d\n", vj->cycle_number);
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

    vj->trace_data[0] = 0x0000001c00000bbaULL;
    xil_printf("verinject: at cycle %15d injected into bit %10d\n", 0x1c, 0xbba);
    membarrier();

    XTime t_run_start, t_run_end;

    XTime_GetTime(&t_run_start);
    vj->running_flags = VERINJECT_AXI_RUNNING_RUN;
    membarrier();
    while(vj->running_flags&VERINJECT_AXI_RUNNING_RUN) {}
    membarrier();
    XTime_GetTime(&t_run_end);

    print("Log for run 1\n");
    print_vj_log();
    print("End log\n");

    xil_printf("Run took %d cycles\n", (u32)(t_run_end - t_run_start));

    cleanup_platform();
    return 0;
}
