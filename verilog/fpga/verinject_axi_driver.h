/*  Verinject AXI driver header
    Version 1.0 - updated 2020-02-19

    Copyright 2020 Jakub Szewczyk

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

#ifndef VERINJECT_AXI_DRIVER_H_INCLUDED
#define VERINJECT_AXI_DRIVER_H_INCLUDED

#include <stdint.h>

#ifndef VERINJECT_AXI_LOG_QWORDS
#define VERINJECT_AXI_LOG_QWORDS 128
#endif

enum verinject_axi_running_bitmask {
    VERINJECT_AXI_RUNNING_NOT = 0,
    VERINJECT_AXI_RUNNING_RUN = 1,
    VERINJECT_AXI_RUNNING_STOP = 2,
    VERINJECT_AXI_RUNNING_FINISHED = 3
};

/// The AXI driver uses an MMIO interface as defined by this struct
typedef struct verinject_axi_interface {
    uint32_t log_qword_count;
    uint32_t trace_qword_count;
    uint32_t cycle_number;
    uint32_t running_flags;
    uint32_t stop_cycle_number;
    uint32_t log_position;
    uint32_t trace_position;
    uint32_t _pad0[2];
    uint64_t log_data[VERINJECT_AXI_LOG_QWORDS];
    uint64_t trace_data[1024];
} verinject_axi_interface;

#endif
