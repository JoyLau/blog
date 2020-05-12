docker run \
-d \
--restart always \
--name blog \
-p 8080:80 \
-p 8081:8081 \
-e PULL_BRANCH='v2.0' \
-e PUSH_GIT_REPO='https://JoyLau:1001520.LiuFa@github.com/JoyLau/blog-public.git' \
-e PUBLIC_GIT_REPO='https://github.com/JoyLau/blog-public.git' \
-e PUSH_BRANCH='v2.0' \
-e MODE='deploy,public' \
nas.joylau.cn:5007/joy/blog.joylau.cn:latest