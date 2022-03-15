FROM debian:bullseye
RUN apt-get update && apt-get install -y wget default-jre procps
RUN wget https://github.com/nf-core/chipseq/archive/refs/tags/1.2.2.tar.gz
RUN tar -xvf 1.2.2.tar.gz
RUN wget -qO- https://get.nextflow.io | bash
        