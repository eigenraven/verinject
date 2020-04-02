#!/bin/bash

TOP=rtl/oc8051_top.v
verilator --language 1364-2001 --xml-only $TOP
