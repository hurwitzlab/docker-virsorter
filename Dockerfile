FROM perl:latest

MAINTAINER Ken Youens-Clark <kyclark@email.arizona.edu>

RUN apt-get update && apt-get install libdb-dev -y

#RUN cpanm File::Which

#RUN cpanm Exception::Class

#RUN cpanm File::Which

#RUN cpanm --force Capture::Tiny

#RUN cpanm --force Bio::Seq

COPY local /usr/local

COPY VirSorter /usr/local/bin/VirSorter

COPY run-virsorter.sh /usr/local/bin/

ENV PATH /usr/local/bin/VirSorter:$PATH

ENV PERL5LIB /usr/local

ENTRYPOINT ["run-virsorter.sh"]

CMD ["-h"]
