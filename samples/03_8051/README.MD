
This is the 8051 core from OpenCores (<https://opencores.org/projects/8051>) adapted for testing with Verinject.


The source has been adapted with the following steps:
 * Ran the preprocessor with `iverilog -E`
 * Put the input/output declarations into module argument list to modernise the code to work with Verinject