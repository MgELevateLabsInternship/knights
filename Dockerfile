FROM ubuntu
RUN apt-get update -y
RUN apt-get -y install apache2
ADD . /var/www/html

# Add ServerName to apache config to suppress the warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

ENV name Devuser-1
ENTRYPOINT apachectl -D FOREGROUND
