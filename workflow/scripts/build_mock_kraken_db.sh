#!/usr/bin/env bash
set -euo pipefail

# Assume kraken2 is installed

# The file should be a fasta (not gzipped) in resources/kraken_mock.fa


# Build db
cat /dev/null > resources/kraken_mock.fa

gzip -dc resources/mags/acutalibacter_ornithocaccae.fna.gz \
| sed '/^>/ s/$/|kraken:taxid|2838416/' \
| seqtk seq \
| head -200 \
>> resources/kraken_mock.fa

gzip -dc resources/mags/scybalocola_faecipullorum.fna.gz \
| sed '/^>/ s/$/|kraken:taxid|2840942/' \
| seqtk seq \
| head -200 \
>> resources/kraken_mock.fa

gzip -dc resources/reference/chrX_sub.fa.gz \
| sed '/^>/ s/$/|kraken:taxid|9606/' \
>> resources/kraken_mock.fa


# Download and format db (this is +40GB once decompressed)
kraken2-build \
    --download-taxonomy \
    --db resources/kraken_mock


# Add fasta
kraken2-build \
    `#--no-masking` \
    --add-to-library resources/kraken_mock.fa \
    --db resources/kraken_mock \
    --threads 4

# Build the db itself
kraken2-build \
    --build \
    --db resources/kraken_mock


# Remove crap
kraken2-build \
    --clean \
    --db resources/kraken_mock


# Test with itself
kraken2 \
    --db resources/kraken_mock \
    --threads 4 \
    --report resources/kraken_mock.report \
    --output resources/kraken_mock.out \
    resources/kraken_mock.fa


# Run on mock reads
kraken2 \
    --db resources/kraken_mock \
    --threads 8 \
    --report results/kraken/GBRF1.1.report \
    --output resources/kraken/GBRF1.1.out \
    --gzip-compressed \
    --paired \
    resources/reads_mixed/GBRF1.1_1.fq.gz \
    resources/reads_mixed/GBRF1.1_2.fq.gz
