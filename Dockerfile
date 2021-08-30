FROM node:16
RUN npm config set registry https://repo.huaweicloud.com/repository/npm/
RUN npm cache clean -f
RUN yarn config set registry https://repo.huaweicloud.com/repository/npm/
RUN npm install hexo-cli@4.2.0 -g