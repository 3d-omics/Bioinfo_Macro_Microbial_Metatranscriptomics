
# As intended
ribodetector_cpu \
    -i SA1_1.fq.gz SA1_2.fq.gz \
    -o test1.fq.gz test2.fq.gz \
    -l 100 \
    -t 24 \
    --chunk_size 1024 \
    -e rrna
# 1 chunk every 7 min


# Input are fifos
mkfifo in_1.fq
mkfifo in_2.fq
pigz -dc SA1_1.fastq.gz > in_1.fq &
pigz -dc SA1_2.fastq.gz > in_2.fq &

ribodetector_cpu \
    -i in_1.fq in_2.fq \
    -o out_1.fq.gz out_1.fq.gz \
    -l 100 \
    -t 24 \
    --chunk_size 1024 \
    -e rrna

rm in_1.fq in_2.fq -rf
rm out_1.fq.gz out_2.fq.gz
# 7 minutes


# outputs are fifos
mkfifo out_1.fq
mkfifo out_2.fq

pigz -1 out_1.fq > out_1.fq.gz &
pigz -1 out_2.fq > out_2.fq.gz &


ribodetector_cpu \
    -i SA1_1.fastq.gz SA1_2.fastq.gz \
    -o out_1.fq out_2.fq \
    -l 100 \
    -t 24 \
    --chunk_size 1024 \
    -e rrna

rm out_1.fq.gz out_2.fq.gz -rf
rm out_1.fq out_2.fq -rf

# Complains because outputs already exist. The pipeline gets stuck.
# The first chunk is processed, but pigz does nothing because is suspended

# inputs and outputs are fifos


# No compression on outputs
