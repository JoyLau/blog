node('master') {
    def nodejs

    try {
        stage('Checkout') {
            checkout scm
            sh 'git reset --hard'
        }

        stage('Prepare docker environment') {
            sh 'curl -fsSL get.docker.com -o get-docker.sh && sh get-docker.sh --mirror Aliyun'
            def dockerImageName = 'node:16'
            nodejs = docker.image(dockerImageName)
        }

        nodejs.inside {
            stage('Install') {
                sh 'npm install -g hexo@4.2.0'
                sh 'hexo --version'
            }
        }
    } catch (e) {
        throw e
    } finally {
        sh 'git reset --hard'
    }
}

