FROM node:latest
MAINTAINER joylau 2587038142.liu@gmail.com
LABEL Descripttion="This image is JoyLau's Bolg"
ENV GIT_REPO="https://github.com/JoyLau/blog.git"
ENV BRANCH master
ENV PROXY=''
EXPOSE 80 8081
ADD sources.list /etc/apt/sources.list
RUN apt-get update &&\
    apt-get install -y gosu nginx git fcgiwrap &&\
    npm install hexo -g &&\
    npm install -g cnpm --registry=https://registry.npm.taobao.org
COPY nginx.default.conf /etc/nginx/sites-available/default
RUN mkdir -p /my-blog/bash /my-blog/logs
COPY *.sh /my-blog/bash/
RUN chown -R www-data:www-data /my-blog &&\
    chmod -R 777 /var/www &&\
    chmod +x /my-blog/bash/*.sh
ENTRYPOINT ["/my-blog/bash/docker-entrypoint.sh"]
CMD ["/my-blog/bash/init.sh"]
