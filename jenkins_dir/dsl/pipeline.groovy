pipelineJob('Pipeline') {
  definition {
    cps {
      sandbox()
      script("""
#!groovy

node {

    currentBuild.result = "SUCCESS"
    sh 'date'

    try {

    	timestamps {
        
       stage 'Pull Sourse Code'
         
            echo 'Pull Source Code'
            git url: "${Repository}"

       stage 'Parse Message'

            def commit = sh(script: 'git rev-parse HEAD', returnStdout: true)
            def message = sh(script: "git log --format=%B -n 1 ${commit}", returnStdout: true)
            def author = sh(script: "git --no-pager show -s --format='%ae' ${commit}", returnStdout: true)
            def items = message.findAll(/[A-Z]{2,10}-[0-9]+/).unique()
       
       stage 'Generate Dockerfile'
        
            echo 'Generate Dockerfile'
            sh '~/bin/generate_dockerfile'

       stage 'Create Container'
            
            echo 'Create Container'
            sh "~/bin/g_create_container"         

       stage 'Run Container'
       
            echo 'Run Container'
            def container = sh(script: '~/bin/g_run_container', returnStdout: true)
       
       stage 'Change Resource Defintions'
       
            echo 'Change Resource Defintions'
            sh "~/bin/g_call_process_config ${container}"
        
       stage 'Run Build'

            echo 'Run Build'
            sh "~/bin/g_run_build ${container}"

       stage 'Take Screenshot'

            echo 'Take Screenshot'
            sh "~/bin/g_call_take_screenshot ${container}"

       stage 'Run Sonar'

            echo  'Run Sonar'
            sh "~/bin/g_run_sonar ${container}"

       stage 'Run Fortify'

            echo 'Run Fortify'
            sh "~/bin/g_run_fortify ${container}"
            
       stage 'Update Jira'

            echo 'Update Jira'
            for (item in items) {
            	sh "~/bin/g_update_jira ${item}"         
            }

       stage 'Archive Artifact'

            echo 'Archive Artifact'
            sh "~/bin/g_call_sendto_artifactory ${container}"

       stage 'Extract Screenshot'

            echo 'Extract Screenshot'
            sh "~/bin/g_extract_screenshot ${container}"

       stage 'Send Email'

            echo 'Send Email'
            sh "~/bin/g_send_email ${author}"
            
       stage 'Kill Container'

            echo 'Kill Container'
            sh "docker stop ${container}"
            sh "docker rm ${container}"

       stage 'Remove Directory'

            echo 'Remove Directory'
            deleteDir()

        }
      }

    catch (err) {

        echo 'Error'
    }
}
      """.stripIndent())      
    }
  }
}
