pipelineJob('Pipeline') {
	scm {
        git {
            remote {
                name('remoteB')
                url('git@server:account/repo1.git')
            }
        }
  }
  definition {
    cps {
      sandbox()
      script("""
node {
    currentBuild.result = "SUCCESS"
    sh 'date'
}
      """.stripIndent())      
    }
  }
}
