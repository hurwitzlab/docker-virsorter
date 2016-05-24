FROM perl:latest

MAINTAINER Ken Youens-Clark <kyclark@email.arizona.edu>

RUN apt-get update && apt-get install libdb-dev -y

RUN cpanm --force Capture::Tiny

RUN cpanm --force BioPerl

RUN cpanm File::Which

COPY VirSorter /usr/local/bin/VirSorter

COPY run-virsorter.sh /usr/local/bin/

COPY bin /usr/local/bin/

ENV PATH /usr/local/bin/VirSorter:$PATH

ENTRYPOINT ["run-virsorter.sh"]

CMD ["-h"]
