import jenkins
import sys

mypass = sys.argv[1]
server = jenkins.Jenkins('http://localhost:8080', username='admin', password=mypass)
version = server.get_version()
print('Hello from Jenkins %s' % ( version))
