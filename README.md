# Docker Virsorter

Docker for Virsorter

# Dependencies

Install the following into a "bin" directory:

* HMMER (http://hmmer.janelia.org/)
* MCL (http://micans.org/mcl/)
* Metagene Annotator (http://metagene.nig.ac.jp/metagene/download_mga.html)
* MUSCLE (http://www.drive5.com/muscle/)
* BLAST (ftp://ftp.ncbi.nlm.nih.gov/blast/executables/release/LATEST/, not BLAST+)

# Data Container

The 12G of dependent data exists as a separate data container 
called "virsorter-data."

This is the Dockerfile for that:

    FROM perl:latest

    MAINTAINER Ken Youens-Clark <kyclark@email.arizona.edu>

    COPY Generic_ref_file.refs /data/

    COPY PFAM_27 /data/PFAM_27

    COPY Phage_gene_catalog /data/Phage_gene_catalog

    COPY Phage_gene_catalog_plus_viromes /data/Phage_gene_catalog_plus_viromes

    COPY SUP05_SAGs_with_viruses.fna /data/

    VOLUME ["/data"]
  
Do a "docker build -t kyclark/virsorter-data ." with that, then:

    $ docker create --name virsorter-data kyclark/virsorter-data /bin/true

# Build

    $ docker build -t kyclark/virsorter .

# Run

A sample "run" command to use the current working directory for input/output:

    $ docker run --rm --volumes-from virsorter-data -v $(pwd):/de-app-work \
    -w /de-app-work kyclark/virsorter --fasta Mic_1.fna

# Authors

Simon Roux <roux.8@osu.edu> is the author of Virsorter

Ken Youens-Clark <kyclark@email.arizona.edu> packaged this for Docker/iPlant.

