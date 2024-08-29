FROM ubuntu

RUN apt-get update
RUN apt-get install -y python3-pip
RUN apt-get install -y python3-flask

ADD ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]