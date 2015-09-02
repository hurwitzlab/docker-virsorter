FROM perl:latest

MAINTAINER Ken Youens-Clark <kyclark@email.arizona.edu>

RUN apt-get update && apt-get install libdb-dev -y

RUN cpanm --force Capture::Tiny

RUN cpanm --force BioPerl

COPY wrapper_phage_contigs_sorter_iPlant.pl /usr/local/bin/

COPY Scripts /usr/local/bin/Scripts/

#COPY lib /usr/local/lib/

COPY bin /usr/local/bin/

ENTRYPOINT ["wrapper_phage_contigs_sorter_iPlant.pl"]

CMD ["-h"]
