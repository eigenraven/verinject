# verinject
(System)Verilog verification code injector - for automatically testing designs agains single bit failures

### .map format
Space-separated values, column headers as follows:
```
"Range start" "Range end" "Path.VarName" "Total bit count" "Left word range" "Right word range" "Left memory size" "Right memory size" "Kind: var/mem"
```
