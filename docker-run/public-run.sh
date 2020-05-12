docker run \
-d \
--restart always \
--name public-blog \
-p 80:80 \
-p 8081:8081 \
-e PUBLIC_GIT_REPO='https://github.com/JoyLau/blog-public.git' \
-e PUSH_BRANCH='v2.0' \
-e MODE='public' \
nas.joylau.cn:5007/joy/blog.joylau.cn:latest