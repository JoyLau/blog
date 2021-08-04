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
    }
}

