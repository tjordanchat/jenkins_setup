import jenkins.model.*
import hudson.model.*
Jenkins.instance.getAllItems(AbstractProject.class).each { println(it.fullName) };
