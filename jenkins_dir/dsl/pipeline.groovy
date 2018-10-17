pipelineJob('seed') {
  definition {
    cps {
      sandbox()
      script("""
node {
    currentBuild.result = "SUCCESS"
    sh 'date'
}
      """.stripIndent())      
    }
  }
}
