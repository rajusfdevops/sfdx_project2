import groovy.json.JsonSlurperClassic

node {
    def BUILD_NUMBER = env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR = "tests/${BUILD_NUMBER}"
    def SFDC_USERNAME

    // Dev2 Environment Variables
    def DEV2_HUB_ORG = 'rajukumarsfdevops-u78v@force.com.dev1'
    def DEV2_SFDC_HOST = 'https://login.salesforce.com'
    def DEV2_JWT_KEY_CRED_ID = 'bde74365-fe66-45fa-886d-0942a42dbba1'
    def DEV2_CONNECTED_APP_CONSUMER_KEY = '3MVG9GOcETU7CVrijp._VcyabJnRtBc16BfyKcVAGnfdBnUioLsHMpwfGmdRXCml3T7WjrWRIB2pzhV9dR05j'

    // Test2 Environment Variables
    def TEST2_HUB_ORG = 'rajukumarsfdevops-u78v@force.com.test1'
    def TEST2_SFDC_HOST = 'https://login.salesforce.com'
    def TEST2_JWT_KEY_CRED_ID = 'bde74365-fe66-45fa-886d-0942a42dbba1'
    def TEST2_CONNECTED_APP_CONSUMER_KEY = '3MVG9.AS5PzgHfpZw43Gr1_K5Qnd4DYJULRBvLBZgemMxnoOe7eU5LaIMKBOwnUXdiLaQxj5xqxB.2WMf8tnQ'

    def toolbelt = tool 'toolbelt'

    stage('Checkout Source') {
        // When running in multi-branch job, one must issue this command
        checkout scm

        // Debugging: List the contents of the checked-out directory
        if (isUnix()) {
            sh 'ls -la'
        } else {
            bat 'dir'
        }
    }

    // Debugging: Print the credentials IDs to ensure they are set
    println "DEV2_HUB_ORG: ${DEV2_HUB_ORG}"
    println "DEV2_SFDC_HOST: ${DEV2_SFDC_HOST}"
    println "DEV2_CONNECTED_APP_CONSUMER_KEY: ${DEV2_CONNECTED_APP_CONSUMER_KEY}"
    println "DEV2_JWT_KEY_CRED_ID: ${DEV2_JWT_KEY_CRED_ID}"
    println "TEST2_HUB_ORG: ${TEST2_HUB_ORG}"
    println "TEST2_SFDC_HOST: ${TEST2_SFDC_HOST}"
    println "TEST2_CONNECTED_APP_CONSUMER_KEY: ${TEST2_CONNECTED_APP_CONSUMER_KEY}"
    println "TEST2_JWT_KEY_CRED_ID: ${TEST2_JWT_KEY_CRED_ID}"

    // Authorize and Deploy to Dev2
    withCredentials([file(credentialsId: DEV2_JWT_KEY_CRED_ID, variable: 'dev2_jwt_key_file')]) {
        stage('Authorize and Deploy to Dev2') {
            def rc
            if (isUnix()) {
                rc = sh returnStatus: true, script: "${toolbelt} force:auth:jwt:grant --clientid ${DEV2_CONNECTED_APP_CONSUMER_KEY} --username ${DEV2_HUB_ORG} --jwtkeyfile ${dev2_jwt_key_file} --setdefaultdevhubusername --instanceurl ${DEV2_SFDC_HOST}"
            } else {
                rc = bat returnStatus: true, script: "\"${toolbelt}\" force:auth:jwt:grant --clientid ${DEV2_CONNECTED_APP_CONSUMER_KEY} --username ${DEV2_HUB_ORG} --jwtkeyfile \"${dev2_jwt_key_file}\" --setdefaultdevhubusername --instanceurl ${DEV2_SFDC_HOST}"
            }
            if (rc != 0) { error 'Dev2 org authorization failed' }

            println rc

            // List the contents of the objects directory
            if (isUnix()) {
                sh 'ls -la force-app/main/default/objects/'
            } else {
                bat 'dir force-app\\main\\default\\objects\\'
            }

            // Deploy metadata to Dev2
            def rmsg
            if (isUnix()) {
                rmsg = sh returnStdout: true, script: "${toolbelt} force:mdapi:deploy -d manifest -u ${DEV2_HUB_ORG} -w 10"
            } else {
                rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:mdapi:deploy -d manifest -u ${DEV2_HUB_ORG} -w 10"
            }

            println rmsg
        }
    }

    // Authorize and Deploy to Test2
    withCredentials([file(credentialsId: TEST2_JWT_KEY_CRED_ID, variable: 'test2_jwt_key_file')]) {
        stage('Authorize and Deploy to Test2') {
            def rc
            if (isUnix()) {
                rc = sh returnStatus: true, script: "${toolbelt} force:auth:jwt:grant --clientid ${TEST2_CONNECTED_APP_CONSUMER_KEY} --username ${TEST2_HUB_ORG} --jwtkeyfile ${test2_jwt_key_file} --setdefaultdevhubusername --instanceurl ${TEST2_SFDC_HOST}"
            } else {
                rc = bat returnStatus: true, script: "\"${toolbelt}\" force:auth:jwt:grant --clientid ${TEST2_CONNECTED_APP_CONSUMER_KEY} --username ${TEST2_HUB_ORG} --jwtkeyfile \"${test2_jwt_key_file}\" --setdefaultdevhubusername --instanceurl ${TEST2_SFDC_HOST}"
            }
            if (rc != 0) { error 'Test2 org authorization failed' }

            println rc

            // Check if MyCustomObject__c.object file exists
            def objectFileExists
            if (isUnix()) {
                objectFileExists = sh returnStatus: true, script: "test -f force-app/main/default/objects/MyCustomObject__c.object"
            } else {
                objectFileExists = bat returnStatus: true, script: "if exist force-app\\main\\default\\objects\\MyCustomObject__c.object (exit 0) else (exit 1)"
            }
            if (objectFileExists != 0) { error 'MyCustomObject__c.object file not found in force-app/main/default/objects directory' }

            // Deploy metadata to Test2
            def rmsg
            if (isUnix()) {
                rmsg = sh returnStdout: true, script: "${toolbelt} force:mdapi:deploy -d manifest -u ${TEST2_HUB_ORG} -w 10"
            } else {
                rmsg = bat returnStdout: true, script: "\"${toolbelt}\" force:mdapi:deploy -d manifest -u ${TEST2_HUB_ORG} -w 10"
            }

            println rmsg
        }
    }
}