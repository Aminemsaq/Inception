FROM debian:bookworm

RUN apt-get update
RUN apt-get install -y nginx openssl

RUN mkdir /etc/nginx/ssl
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
    -out /etc/nginx/ssl/amsaq.crt \
    -keyout /etc/nginx/ssl/amsaq.key \
    -subj "/C=MA/ST=Khouribga/L=Khouribga/O=42School/OU=amsaq/CN=amsaq.42.fr/"

COPY ./conf/nginx.conf /etc/nginx/conf.d/

RUN mkdir -p /run/nginx

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
