TOTALRUNS=1000
echo 0xffffffffffffffffULL,
TMPF=$(mktemp)
for RUN in $(seq $TOTALRUNS)
do
    ../../vj-gentrace ./injected/top.map --seed $RUN --cycles 256 --faults 1 > $TMPF
    printf "0x%sULL,\n" $(cat $TMPF | head -n 1)
done
