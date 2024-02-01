node('node') {
    def nodejs

    try {
        stage('Checkout') {
            checkout scm
        }

        stage('Prepare docker environment') {
            def dockerImageName = 'node:hexo-7.1.1'
            def dockerBuildOpts = '-f Dockerfile .'
            nodejs = docker.build(dockerImageName, dockerBuildOpts)
        }

        nodejs.inside {
            stage('Build') {
                sh 'npm config set registry https://registry.npmmirror.com'
                sh 'yarn config set registry https://registry.npmmirror.com'
                sh 'yarn install --verbose'
                sh 'rm -rf public.tar.gz'
                sh 'hexo clean'
                sh 'hexo g'
                sh 'tar -czvf public.tar.gz public'
            }

            stage('Deploy') {
                if (env.BRANCH_NAME == 'v3.0') {
                    def remote = [:]
                    remote.name = "joylau.cn"
                    remote.host = "joylau.cn"
                    remote.port = 22
                    remote.allowAnyHosts = true
                    withCredentials([usernamePassword(credentialsId: 'blog.joylau.cn', passwordVariable: 'password', usernameVariable: 'username')]) {
                        remote.user = username
                        remote.password = password
                    }
                    sshPut remote: remote, from: "public.tar.gz", into: "/tmp/"
                    sshCommand remote: remote, command: "cd /tmp/ && tar -zxvf public.tar.gz && rm -rf " +
                            "/home/my-resources/nginx/blog/public && mv /tmp/public /home/my-resources/nginx/blog"
                } else {
                    echo '该分支不支持自动部署。'
                }
            }
        }
    } catch (e) {
        throw e
    } finally {
        sh 'git reset --hard'
    }
}

