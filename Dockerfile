FROM node:16
RUN npm config set registry https://registry.npmmirror.com
RUN npm cache clean -f
RUN yarn config set registry https://registry.npmmirror.com
RUN npm install hexo-cli@4.3.1 -g