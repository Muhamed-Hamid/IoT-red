env.ECR = '{Your Registry endpoint}'

node("master") {
   checkout scm

   stage("Integration") {
      try {
         sh "docker build -t node-red ."
	 //sh "docker run -it -d -u 0 -p 1880:1880 -v node-red:/data -e FLOWS=/data/*.json --name node-red-test node-red"
      }
      catch(e) {
         error "Integration failed"
      }finally {
         sh "docker rm -f node-red || true"
	 sh "docker ps -aq | xargs docker rm || true"
	 sh "docker images -aq -f dangling=true | xargs docker rmi || true"
      }
   }
   stage("Building") {
      sh "docker build -t ${ECR}/node-red:latest ."
   }
   stage("Pushing") {
      docker.withRegistry('https://amazonaws.com/node-red','ecr:us-east-1:ECR-cred') {
         docker.image('node-red').push('latest')
      }
   }
   stage("Create service or Update") {
      try {
         sh '''
           #create service within swarm to easily scale
	   SERVICES=$(docker service ls --filter name=node-red --quiet | wc -l)
	   if [[ $SERVICES -eq 0 ]]; then
	      docker service create --network swarm-netW --name node-red -p 1880:1880 amazonaws.com/node-red:latest
	   else 
	      docker service update --image amazonaws.com/node-red:latest node-red
	      for i in `docker ps | awk 'NR > 1 {print $1}'`; do docker stop $i && docker start $i;done
	   fi
	    '''
     }
     catch(e) {
         error "Update failed - rolling back"
     } 
   }
}
