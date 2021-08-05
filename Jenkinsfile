node('node') {
    def nodejs

    try {
        stage('Checkout') {
            checkout scm
            sh 'git reset --hard'
        }

        stage('Prepare docker environment') {
            def dockerImageName = 'node:16'
            nodejs = docker.image(dockerImageName)
        }

        nodejs.inside {
            stage('Install Hexo') {
                sh 'npm install hexo-cli@4.2.0 -g'
//                 sh 'hexo --version'
            }

            stage('Build') {
                sh 'yarn install'
                sh 'hexo clean'
                sh 'hexo g'
            }
        }
    } catch (e) {
        throw e
    } finally {
        sh 'git reset --hard'

        dingtalk (
            robot: '23443acc-1f74-4b59-801e-7a97389b7962',
            type: 'ACTION_CARD',
            title: 'Jenkins 流水线消息',
            text: [
            '![](http://nas.joylau.cn:5016/1920x1080)',
            '流水线构建成功！'
            ],
        )
    }
}

