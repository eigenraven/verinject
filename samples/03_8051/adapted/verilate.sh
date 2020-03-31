#!/bin/bash

TOP=rtl/oc8051_decoder.v
verilator --xml-only $TOP
