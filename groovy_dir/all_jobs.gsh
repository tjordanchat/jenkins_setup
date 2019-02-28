Jenkins.instance.getAllItems(Job.class).each{ println it.name + " - " + it.class }
