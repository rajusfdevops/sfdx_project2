import groovy.json.JsonSlurperClassic

node {
    def BUILD_NUMBER = env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR = "tests/${BUILD_NUMBER}"
    def SFDC_USERNAME

    // Dev1 Environment Variables
    def DEV1_HUB_ORG = 'rajukumarsfdevops-u78v@force.com.dev1'
    def DEV1_SFDC_HOST = 'https://login.salesforce.com'
    def DEV1_JWT_KEY_CRED_ID = 'bde74365-fe66-45fa-886d-0942a42dbba1'
    def DEV1_CONNECTED_APP_CONSUMER_KEY = '3MVG9GOcETU7CVrijp._VcyabJnRtBc16BfyKcVAGnfdBnUioLsHMpwfGmdRXCml3T7WjrWRIB2pzhV9dR05j'

    // Test1 Environment Variables
    def TEST1_HUB_ORG = 'rajukumarsfdevops-u78v@force.com.test1'
    def TEST1_SFDC_HOST = 'https://login.salesforce.com'
    def TEST1_JWT_KEY_CRED_ID = 'bde74365-fe66-45fa-886d-0942a42dbba1'
    def TEST1_CONNECTED_APP_CONSUMER_KEY = '3MVG9.AS5PzgHfpZw43Gr1_K5Qnd4DYJULRBvLBZgemMxnoOe7eU5LaIMKBOwnUXdiLaQxj5xqxB.2WMf8tnQ'

    def toolbelt = tool 'toolbelt'

    stage('Checkout Source') {
        // When running in multi-branch job, one must issue this command
        checkout scm

        // Debugging: List the contents of the checked-out directory
        if (isUnix()) {
            sh 'ls -la'
            sh 'ls -la force-app/main/default/objects/'
            sh 'ls -la manifest/'
        } else {
            bat 'dir'
            bat 'dir force-app\\main\\default\\objects\\'
            bat 'dir manifest\\'
        }
    }

    // Debugging: Print the credentials IDs to ensure they are set
    println "DEV1_HUB_ORG: ${DEV1_HUB_ORG}"
    println "DEV1_SFDC_HOST: ${DEV1_SFDC_HOST}"
    println "DEV1_CONNECTED_APP_CONSUMER_KEY: ${DEV1_CONNECTED_APP_CONSUMER_KEY}"
    println "DEV1_JWT_KEY_CRED_ID: ${DEV1_JWT_KEY_CRED_ID}"
    println "TEST1_HUB_ORG: ${TEST1_HUB_ORG}"
    println "TEST1_SFDC_HOST: ${TEST1_SFDC_HOST}"
    println "TEST1_CONNECTED_APP_CONSUMER_KEY: ${TEST1_CONNECTED_APP_CONSUMER_KEY}"
    println "TEST1_JWT_KEY_CRED_ID: ${TEST1_JWT_KEY_CRED_ID}"

    // Authorize and Deploy to Dev1
    withCredentials([file(credentialsId: DEV1_JWT_KEY_CRED_ID, variable: 'dev1_jwt_key_file')]) {
        stage('Authorize and Deploy to Dev1') {
            def rc
            if (isUnix()) {
                rc = sh returnStatus: true, script: "${toolbelt} force:auth:jwt:grant --clientid ${DEV1_CONNECTED_APP_CONSUMER_KEY} --username ${DEV1_HUB_ORG} --jwtkeyfile ${dev1_jwt_key_file} --setdefaultdevhubusername --instanceurl ${DEV1_SFDC_HOST}"
            } else {
                rc = bat returnStatus: true, script: "\"${toolbelt}\" force:auth:jwt:grant --clientid ${DEV1_CONNECTED_APP_CONSUMER_KEY} --username ${DEV1_HUB_ORG} --jwtkeyfile \"${dev1_jwt_key_file}\" --setdefaultdevhubusername --instanceurl ${DEV1_SFDC_HOST}"
            }
            if (rc != 0) { error 'Dev1 org authorization failed' }

            println rc

            // List the contents of the objects directory
            if (isUnix()) {
                sh 'ls -la force-app/main/default/objects/'
            } else {
                bat 'dir force-app\\main\\default\\objects\\'
            }

            // Deploy metadata to Dev1
            def rmsg
            if (isUnix()) {
                rmsg = sh returnStdout: true, script: "${toolbelt} force:mdapi:deploy -d manifest -u ${DEV1_HUB_ORG} -w 10"
            } else {
                rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:mdapi:deploy -d manifest -u ${DEV1_HUB_ORG} -w 10"
            }

            println rmsg
        }
    }

    // Authorize and Deploy to Test1
    withCredentials([file(credentialsId: TEST1_JWT_KEY_CRED_ID, variable: 'test1_jwt_key_file')]) {
        stage('Authorize and Deploy to Test1') {
            def rc
            if (isUnix()) {
                rc = sh returnStatus: true, script: "${toolbelt} force:auth:jwt:grant --clientid ${TEST1_CONNECTED_APP_CONSUMER_KEY} --username ${TEST1_HUB_ORG} --jwtkeyfile ${test1_jwt_key_file} --setdefaultdevhubusername --instanceurl ${TEST1_SFDC_HOST}"
            } else {
                rc = bat returnStatus: true, script: "\"${toolbelt}\" force:auth:jwt:grant --clientid ${TEST1_CONNECTED_APP_CONSUMER_KEY} --username ${TEST1_HUB_ORG} --jwtkeyfile \"${test1_jwt_key_file}\" --setdefaultdevhubusername --instanceurl ${TEST1_SFDC_HOST}"
            }
            if (rc != 0) { error 'Test1 org authorization failed' }

            println rc

            // Check if MyCustomObject__c.object file exists
            def objectFileExists
            if (isUnix()) {
                objectFileExists = sh returnStatus: true, script: "test -f force-app/main/default/objects/MyCustomObject__c.object"
            } else {
                objectFileExists = bat returnStatus: true, script: "if exist force-app\\main\\default\\objects\\MyCustomObject__c.object (exit 0) else (exit 1)"
            }
            if (objectFileExists != 0) { error 'MyCustomObject__c.object file not found in force-app/main/default/objects directory' }

            // Deploy metadata to Test1
            def rmsg
            if (isUnix()) {
                rmsg = sh returnStdout: true, script: "${toolbelt} force:mdapi:deploy -d manifest -u ${TEST1_HUB_ORG} -w 10"
            } else {
                rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:mdapi:deploy -d manifest -u ${TEST1_HUB_ORG} -w 10"
            }

            println rmsg
        }
    }
}