FROM debian:bookworm

RUN apt-get update && apt-get install -y nginx openssl

RUN mkdir /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/amsaq.key \
    -out /etc/nginx/ssl/amsaq.crt \
    -subj "/C=MA/ST=Khouribga/L=Khouribga/O=42/CN=amsaq.42.fr"

COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]  