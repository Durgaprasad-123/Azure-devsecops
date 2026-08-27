pipeline {
    agent any

    environment {
        AZURE_CRED_ID           = 'Azure-credential-id'

        ACR_NAME                = 'acrbqssk'
        ACR_LOGIN_SERVER        = 'acrbqssk.azurecr.io'
        IMAGE_NAME               = 'juiceshop'
        IMAGE_TAG                 = "${env.BUILD_NUMBER}"
        FULL_IMAGE               = "${ACR_LOGIN_SERVER}/${IMAGE_NAME}:${IMAGE_TAG}"

        AKS_RESOURCE_GROUP       = 'rg-devsecops'
        AKS_CLUSTER_NAME         = 'aksjdchq'
        K8S_NAMESPACE             = 'default'
        K8S_DEPLOYMENT             = 'juice-shop'
        K8S_CONTAINER             = 'juice-shop'
        K8S_SERVICE               = 'juice-shop'

        DEFECTDOJO_URL           = '<vm-ip>:8080'
        DEFECTDOJO_PRODUCT_TYPE = 'DevSecOps'
        DEFECTDOJO_PRODUCT_NAME = 'Owasp-Juiceshop'
        DEFECTDOJO_ENGAGEMENT   = 'CI-Pipeline'
        
        SONAR_HOST_URL           = '<vm-ip>:9000/sonarqube'
        SONAR_PROJECT_KEY        = 'owasp-juiceshop'
    }

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
                            credentialID: env.AZURE_CRED_ID,
                            secrets: [[envVariable: 'SONAR_TOKEN', name: 'sonarqube', secretType: 'Secret']]
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

        stage('Generate SonarQube Report') {
            steps {
                dir('app') {
                    script {
                        azureKeyVault(
                            credentialID: env.AZURE_CRED_ID,
                            secrets: [[envVariable: 'SONAR_TOKEN', name: 'sonarqube', secretType: 'Secret']]
                        ) {
                        
                            sh """
                                curl -sv --max-time 20 -u "\$SONAR_TOKEN:" \
                                  -w "\\nHTTP_STATUS=%{http_code}\\n" \
                                  "${SONAR_HOST_URL}/api/issues/search?componentKeys=${SONAR_PROJECT_KEY}&resolved=false&ps=500" \
                                  -o sonarqube_results.json

                                echo "SonarQube report size:"
                                ls -lah sonarqube_results.json
                                echo "First 200 chars of response:"
                                head -c 200 sonarqube_results.json
                            """
                        }
                    }
                }
                archiveArtifacts artifacts: 'app/sonarqube_results.json', allowEmptyArchive: true
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                dir('app') {
                    script {
                        azureKeyVault(
                            credentialID: env.AZURE_CRED_ID,
                            secrets: [[envVariable: 'NVD_API_KEY', name: 'nvd-api-key', secretType: 'Secret']]
                        ) {
                            dependencyCheck additionalArguments: """
                                --scan .
                                --format XML
                                --format HTML
                                --nvdApiKey \$NVD_API_KEY
                            """,
                            odcInstallation: 'DependencyCheck'
                        }
                    }
                }
            }
        }

        stage('Publish Dependency Check Report') {
            steps {
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Trivy Filesystem Scan') {
            steps {
                dir('app') {
                    sh '''
                        trivy fs --exit-code 0 --severity HIGH,CRITICAL \
                          --format json -o trivy-fs-report.json .
                        trivy fs --exit-code 0 --severity HIGH,CRITICAL \
                          --format table .
                    '''
                }
                archiveArtifacts artifacts: 'app/trivy-fs-report.json', allowEmptyArchive: true
            }
        }

        stage('Build Docker Image') {
            steps {
                dir('app') {
                    sh "docker build -t ${FULL_IMAGE} ."
                }
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh """
                    trivy image --exit-code 0 --severity HIGH,CRITICAL \
                      --format json -o trivy-image-report.json ${FULL_IMAGE}
                    trivy image --exit-code 0 --severity HIGH,CRITICAL \
                      --format table ${FULL_IMAGE}
                """
                archiveArtifacts artifacts: 'trivy-image-report.json', allowEmptyArchive: true
            }
        }

        stage('Push Image to ACR') {
            steps {
                script {
                    azureKeyVault(
                        credentialID: env.AZURE_CRED_ID,
                        secrets: [
                            [envVariable: 'ACR_USERNAME', name: 'acr-username', secretType: 'Secret'],
                            [envVariable: 'ACR_PASSWORD', name: 'acr-password', secretType: 'Secret']
                        ]
                    ) {
                        sh """
                            echo \$ACR_PASSWORD | docker login ${ACR_LOGIN_SERVER} -u \$ACR_USERNAME --password-stdin
                            docker push ${FULL_IMAGE}
                            docker logout ${ACR_LOGIN_SERVER}
                        """
                    }
                }
            }
        }

        stage('Connect to AKS') {
            steps {
                sh """
                    az login --identity
                    az aks get-credentials \
                      --resource-group ${AKS_RESOURCE_GROUP} \
                      --name ${AKS_CLUSTER_NAME} \
                      --overwrite-existing
                """
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                sh """
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    kubectl set image deployment/${K8S_DEPLOYMENT} \
                      ${K8S_CONTAINER}=${FULL_IMAGE} -n ${K8S_NAMESPACE}
                    kubectl rollout status deployment/${K8S_DEPLOYMENT} -n ${K8S_NAMESPACE} --timeout=180s
                """
            }
        }

        stage('DAST - OWASP ZAP Scan') {
            steps {
                script {
                    env.TARGET_URL = sh(
                        script: """
                            IP=\$(kubectl get svc ${K8S_SERVICE} -n ${K8S_NAMESPACE} -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
                            echo "http://\${IP}"
                        """,
                        returnStdout: true
                    ).trim()
                    echo "ZAP Target URL: ${env.TARGET_URL}"
                }
                sh '''
                    mkdir -p zap-report
                    echo "Current directory:"
                    pwd
                    echo "Target URL: $TARGET_URL"

                    ZAP_VOLUME="zap-vol-${BUILD_NUMBER}"
                    ZAP_CONTAINER="zap-run-${BUILD_NUMBER}"

                    docker volume create "$ZAP_VOLUME"

                    docker run --user root \
                        --name "$ZAP_CONTAINER" \
                        -v "$ZAP_VOLUME:/zap/wrk:rw" \
                        ghcr.io/zaproxy/zaproxy:stable zap-baseline.py \
                        -t $TARGET_URL \
                        -r zap-report.html -x zap-report.xml -J zap-report.json || true

                    docker cp "$ZAP_CONTAINER:/zap/wrk/." ./zap-report/

                    docker rm -f "$ZAP_CONTAINER" || true
                    docker volume rm "$ZAP_VOLUME" || true

                    echo "======zap-file======"
                    ls -lah zap-report/
                '''
                sh '''
                    if [ ! -s zap-report/zap-report.xml ]; then
                        echo "ERROR: zap-report.xml was not generated. Check the ZAP container logs above."
                        exit 1
                    fi
                '''

                archiveArtifacts artifacts: 'zap-report/*', allowEmptyArchive: true
            }
        }

        stage('Publish All Reports to DefectDojo') {
            steps {
                script {
                    azureKeyVault(
                        credentialID: env.AZURE_CRED_ID,
                        secrets: [[envVariable: 'DEFECTDOJO_API_KEY', name: 'Defect-Dojo', secretType: 'Secret']]
                    ) {
                        dir('app') {
                            sh """
                                curl -s -X POST "${DEFECTDOJO_URL}/api/v2/import-scan/" \
                                  -H "Authorization: Token \$DEFECTDOJO_API_KEY" \
                                  -F "scan_type=Dependency Check Scan" \
                                  -F "file=@dependency-check-report.xml" \
                                  -F "product_name=${DEFECTDOJO_PRODUCT_NAME}" \
                                  -F "product_type_name=${DEFECTDOJO_PRODUCT_TYPE}" \
                                  -F "engagement_name=${DEFECTDOJO_ENGAGEMENT}" \
                                  -F "auto_create_context=true"

                                curl -s -X POST "${DEFECTDOJO_URL}/api/v2/import-scan/" \
                                  -H "Authorization: Token \$DEFECTDOJO_API_KEY" \
                                  -F "scan_type=Trivy Scan" \
                                  -F "file=@trivy-fs-report.json" \
                                  -F "product_name=${DEFECTDOJO_PRODUCT_NAME}" \
                                  -F "product_type_name=${DEFECTDOJO_PRODUCT_TYPE}" \
                                  -F "engagement_name=${DEFECTDOJO_ENGAGEMENT}" \
                                  -F "auto_create_context=true"

                                echo "SonarQube report present?"
                                ls -lah sonarqube_results.json

                                curl -s -X POST "${DEFECTDOJO_URL}/api/v2/import-scan/" \
                                  -H "Authorization: Token \$DEFECTDOJO_API_KEY" \
                                  -F "scan_type=SonarQube Scan" \
                                  -F "file=@sonarqube_results.json" \
                                  -F "product_name=${DEFECTDOJO_PRODUCT_NAME}" \
                                  -F "product_type_name=${DEFECTDOJO_PRODUCT_TYPE}" \
                                  -F "engagement_name=${DEFECTDOJO_ENGAGEMENT}" \
                                  -F "auto_create_context=true"
                            """
                        }

                        sh """
                            curl -s -X POST "${DEFECTDOJO_URL}/api/v2/import-scan/" \
                              -H "Authorization: Token \$DEFECTDOJO_API_KEY" \
                              -F "scan_type=Trivy Scan" \
                              -F "file=@trivy-image-report.json" \
                              -F "product_name=${DEFECTDOJO_PRODUCT_NAME}" \
                              -F "product_type_name=${DEFECTDOJO_PRODUCT_TYPE}" \
                              -F "engagement_name=${DEFECTDOJO_ENGAGEMENT}" \
                              -F "auto_create_context=true"

                            echo "ZAP report present at publish time?"
                            ls -lah "\${WORKSPACE}/zap-report/"

                            curl -s -X POST "${DEFECTDOJO_URL}/api/v2/import-scan/" \
                              -H "Authorization: Token \$DEFECTDOJO_API_KEY" \
                              -F "scan_type=ZAP Scan" \
                              -F "file=@\${WORKSPACE}/zap-report/zap-report.xml" \
                              -F "product_name=${DEFECTDOJO_PRODUCT_NAME}" \
                              -F "product_type_name=${DEFECTDOJO_PRODUCT_TYPE}" \
                              -F "engagement_name=${DEFECTDOJO_ENGAGEMENT}" \
                              -F "auto_create_context=true"
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: '**/*report*.*', allowEmptyArchive: true
            cleanWs()
        }
    }
}