pipelineJob('Pipeline') {
  definition {
    cps {
      sandbox()
      script("""
        stage('init') {
          build 'Pipeline-init'
        } 
        stage('build') {
          build 'Pipeline-build'
        }
      """.stripIndent())      
    }
  }
}
