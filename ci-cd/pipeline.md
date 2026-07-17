pipeline {
    agent any

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Durgaprasad-123/Azure-devsecops.git'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                dir('app') {
                    script {

                        def scannerHome = tool 'SonarQube'

                        azureKeyVault(
                            credentialID: '98c35e6d-024d-4cea-8a6c-7518ca8577f9',
                            secrets: [
                                [
                                    envVariable: 'SONAR_TOKEN',
                                    name: 'sonarqube',
                                    secretType: 'Secret'
                                ]
                            ]
                        ) {

                            withSonarQubeEnv('SonarQube') {

                                sh """
                                    ${scannerHome}/bin/sonar-scanner \
                                      -Dsonar.projectKey=owasp-juiceshop \
                                      -Dsonar.sources=. \
                                      -Dsonar.sourceEncoding=UTF-8 \
                                      -Dsonar.token=\$SONAR_TOKEN
                                """
                            }
                        }
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
        stage('OWASP Dependency Check') {
            steps {
                dir('app') {
                dependencyCheck additionalArguments: '''
                --scan .
                --format XML
                --format HTML
                --nvdApiKey YOUR_API_KEY
                ''',
                odcInstallation: 'DependencyCheck'
                    }
            }
        }
        stage('Publish Dependency Check Report') {
            steps {
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
    }
}
