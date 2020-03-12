//////////////////////////////////////////////////////////////////////
////                                                              ////
////  8051 cores Definitions              		          ////
////                                                              ////
////  This file is part of the 8051 cores project                 ////
////  http://www.opencores.org/cores/8051/                        ////
////                                                              ////
////  Description                                                 ////
////  8051 definitions.                                           ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Simon Teran, simont@opencores.org                     ////
////      - Jaka Simsic, jakas@opencores.org                      ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// ver: 1
//

//
// oc8051 pherypherals
//










//
// oc8051 ITERNAL ROM
//
//`define OC8051_ROM


//
// oc8051 memory
//
//`define OC8051_CACHE
//`define OC8051_WB

//`define OC8051_RAM_XILINX
//`define OC8051_RAM_VIRTUALSILICON





//
// oc8051 simulation defines
//
//`define OC8051_SIMULATION
//`define OC8051_SERIAL

//
// oc8051 bist
//
//`define OC8051_BIST


//
// operation codes for alu
//



















//
// sfr addresses
//









































//
// sfr bit addresses
//














//
//carry input in alu
//






//
// instruction set
//

//op_code [4:0]



//op_code [7:3]

















//op_code [7:1]



















//op_code [7:0]













































































//
// default values (used after reset)
//


































//
// alu source 1 select
//









//
// alu source 2 select
//







//
// alu source 3 select
//


//`define OC8051_AS3_PCU  3'b101 // program clunter not registered



//
//write sfr
//






//
// ram read select
//













//
// ram write select
//










//
// pc in select
//









//
// compare source select
//







//
// pc Write
//



//
//psw set
//





//
// rom address select
//



////
//// write accumulator
////
//`define OC8051_WA_N 1'b0 // not
//`define OC8051_WA_Y 1'b1 // yes


//
//memory action select
//








////////////////////////////////////////////////////

//
// Timer/Counter modes
//







//
// Interrupt numbers (vectors)
//









//
// interrupt levels
//




//
// interrupt sources
//










//
// miscellaneus
//





//
// read modify write instruction
//




