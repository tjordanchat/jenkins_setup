import jenkins
import sys

server = jenkins.Jenkins('http://localhost:8080', username='admin', password='mypassword')
user = server.get_whoami()
version = server.get_version()
print('Hello %s from Jenkins %s' % (user['fullName'], version))
