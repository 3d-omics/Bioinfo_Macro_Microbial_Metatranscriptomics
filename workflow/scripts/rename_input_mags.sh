#!/usr/bin/env bash

set -euo pipefail

# https://stackoverflow.com/questions/68941265/how-can-i-attach-in-each-header-of-a-fasta-file-the-filename


cat /dev/null > mags.fa

for file in *.fa.gz ; do
    mag_id=$(echo $file | sed 's/.fa.gz$//g')

    gzip -dc $file \
    | awk -v mag_id=$mag_id 'sub(/^>/,"") { $0=">" mag_id "^" $0} 1' \
    >> mags.fa

done
