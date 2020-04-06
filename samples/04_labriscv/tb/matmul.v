`timescale 1ns / 1ps

`default_nettype none
module tb();

`include "params.v"

reg clk;
reg rst;

reg [3:1] zybo_buttons; // Three button inputs
reg [1:0] sw_a; // Two switch inputs

wire [3:0] leds; // Four output LEDs
wire [7:0] ssd_a; // Seven-Segment Display outputs


//==== Run control/status interface ==========================================
//
wire  [1:0]     run_cmd_mode;       // halt, run, step_cycle or step_inst
wire            cpu_commit;         // 1 => a CPU event was committed
wire            cpu_running;        // 0 => CPU halted, 1 => CPU running

//==== Single-step request interface =========================================
//
wire            step_cycle;         // 0->1 is a cycle-step request
wire            step_instr;         // 0->1 is an instruction-step request
wire            step_ack;           // 0->1 when step is complete (4-cycle)

//==== Debugger halt/resume interface ========================================
//
wire            dbg_halt_core;      // 1 => halt core, 1-cycle pulse command
wire            dbg_run_core;       // 1 => run core, 1-cycle pulse command

//==== Frame-buffer display read/write interface ==============================
//
wire            px_request;         // active-high FB request
wire            px_write;           // 1=> write FB, 0 => read FB
wire            px_ready_a;         // async: 1=> write done or data ready
wire            px_ready;           // sync:  1=> write done or data ready
wire  [15:0]    px_address;         // select cols 0..255 within FB
wire  [23:0]    px_write_data;      // pixel value to be written to FB
wire  [23:0]    px_read_data;       // pixel value read from FB

//==== msec timer interface ==================================================
//
wire  [31:0]    msec_elapsed;       // milliseconds elapsed since reset

reg             step_detect_r;
reg             run_detect_r;
reg             halt_detect_r;

assign step_cycle     = zybo_buttons[3] & !step_detect_r;
assign step_instr     = 1'b0;
assign dbg_halt_core  = zybo_buttons[2] & !halt_detect_r;
assign dbg_run_core   = zybo_buttons[1] & !run_detect_r;

always @(posedge clk or posedge rst)
begin : detect_reg_PROC
    if (rst)
    begin
        run_detect_r  <= 1'b0;
        halt_detect_r <= 1'b0;
        step_detect_r <= 1'b0;
    end
    else
    begin
        run_detect_r  <= zybo_buttons[1];
        halt_detect_r <= zybo_buttons[2];
        step_detect_r <= zybo_buttons[3];
    end
end // detect_reg_PROC

wire [31:0] verinject__injector_state;
assign verinject__injector_state = 32'hFFFF_FFFF;

/*
cpu u_cpu(
*/
cpu__injected u_cpu( .verinject__injector_state(verinject__injector_state),
  .clk              (clk            ), // external clock source
  .reset            (rst          ), // async reset input
 
  //==== Run control/status interface ==========================================
  //
  .run_cmd_mode     (run_cmd_mode   ), // halt, run, step_cycle or step_inst
  .cpu_commit       (cpu_commit     ), // 1 => a CPU event was committed
  .cpu_running      (cpu_running    ), // 0 => CPU halted, 1 => CPU running
   
  //==== Single-step request interface =========================================
  //
  .step_cycle       (step_cycle     ), // 0->1 is a cycle-step request
  .step_instr       (step_instr     ), // 0->1 is an instruction-step request
  .step_ack         (step_ack       ), // 0->1 when step is complete (4-cycle)
 
  //==== Debugger halt/resume interface ========================================
  //
  .dbg_halt_core    (dbg_halt_core  ), // 1 => halt core, 1-cycle pulse command
  .dbg_run_core     (dbg_run_core   ), // 1 => run core, 1-cycle pulse command

  //==== Direct Memory Interface for ICCM write and DCCM read/write ============
  //
  // TBD
   
  //==== Bidirectional data link interface to host system ======================
  //
  .hlnk_in_data     (32'd0          ), // hostlink input channel data
  .hlnk_in_valid    (1'b0           ), // hostlink input channel valid data
  .hlnk_in_accept   (),                // hostlink input channel data accept
  //
  .hlnk_out_data    (),                // hostlink input channel data
  .hlnk_out_valid   (),                // hostlink input channel valid data
  .hlnk_out_accept  (1'b1           ), // hostlink input channel data accept
   
  // Interface signals for reading from, and writing to, the VGA display buffer
  //
  .px_request       (px_request     ), // active-high FB request
  .px_write         (px_write       ), // 1=> write FB, 0 => read FB
  .px_ready         (px_ready       ), // 1=> write done or read data ready
  .px_address       (px_address     ), // select cols 0..255 within FB
  .px_write_data    (px_write_data  ), // pixel value to be written to FB
  .px_read_data     (px_read_data   ), // pixel value read from FB
   
  //==== msec timer interface ==================================================
  //
  .msec_elapsed     (msec_elapsed   ), // milliseconds elapsed since reset

  //==== GPIO interface to switches, SSD and LEDs ==============================
  //
  .zybo_switches    (sw_a  ), // current switch settings on ZYBO board
  .zybo_buttons     (zybo_buttons   ), // current value of push buttons on ZYBO
  .zybo_leds        (leds     ), // output to the LEDs on the ZYBO board
  .zybo_ssd         (ssd_a  )  // ouptut to the 7-segment display PMOD
 );

reg     halted;
integer timer = 0;

/// Testbench intialization
initial
begin
    rst    = 1'b1;
    zybo_buttons    = 3'd0;
    clk   = 1'b0;
    sw_a = 2'd0;
    halted   = 1'b0;
    $dumpfile("wave_matmul.vcd");
    $dumpvars;

    #50 rst = 1'b0;

    #100 zybo_buttons[1] = 1'b1;
    #120 zybo_buttons[1] = 1'b0;

    #10000 sw_a = 2'b01;

    #100000 $finish();
end

/// Clock simulation
initial forever
begin
    #4 clk = !clk;
    timer = timer + 1;
end


integer mi;
reg [31:0] mel = 0;
/// LED logging
always @(leds)
begin
    if (timer > 1)
    begin
        $display("LEDs change @t=%d : %d", timer, leds);
        if (leds == 3)
        begin
            $display("Matrix:");
            for (mi = 0; mi < 36; mi++)
            begin
                mel[7:0] = u_cpu.u_exec_unit.u_dccm_ram.dccm_b0[mi];
                mel[15:8] = u_cpu.u_exec_unit.u_dccm_ram.dccm_b1[mi];
                mel[23:16] = u_cpu.u_exec_unit.u_dccm_ram.dccm_b2[mi];
                mel[31:24] = u_cpu.u_exec_unit.u_dccm_ram.dccm_b3[mi];
                $write("%08x,", mel);
            end
            $display("");
            #2 $finish();
        end
    end
end
always @(ssd_a)
begin
    if (timer > 1)
        $display("SSD change @t=%d : %d", timer, ssd_a);
end

endmodule
