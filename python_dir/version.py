from jenkinsapi.jenkins import Jenkins
import sys

print 'First argument is:', sys.argv[1]

def get_server_instance():
   jenkins_url = 'http://127.0.0.1:8080'
   server = Jenkins(jenkins_url, username='admin', password='foopassword')
   return server
  
if __name__ == '__main__':
   print get_server_instance().version
