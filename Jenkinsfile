node('node') {
    def nodejs

    try {
        stage('Checkout') {
            checkout scm
        }

        stage('Prepare docker environment') {
            def dockerImageName = 'node:hexo-4.2.0'
            def dockerBuildOpts = '-f Dockerfile .'
            nodejs = docker.build(dockerImageName, dockerBuildOpts)
        }

        nodejs.inside {
            stage('Build') {
                sh 'yarn install --verbose'
                sh 'hexo clean'
                sh 'hexo g'
            }

            stage('Deploy') {
                if (env.BRANCH_NAME == 'v2.0') {
                    def remote = [:]
                    remote.name = "blog.joylau.cn"
                    remote.host = "blog.joylau.cn"
                    remote.port = 22
                    remote.allowAnyHosts = true
                    withCredentials([usernamePassword(credentialsId: 'blog.joylau.cn', passwordVariable: 'password', usernameVariable: 'username')]) {
                        remote.user = username
                        remote.password = password
                    }
                    def folder = '/home/my-resources/nginx/blog'
                    sshPut remote: remote, from: "public", into: "${folder}"
                    // sshCommand remote: remote, command: "unzip -o ${folder}/backup/${zipFileName} -d ${folder}/data"
                    echo '部署到 blog.joylau.cn。'
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

