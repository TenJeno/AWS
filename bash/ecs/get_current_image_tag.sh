# Searches for RUNNING (Not Pending) Image Tag
# Note that both JQ and AWS CLI must be installed.
# Default credentials must be configured for AWS CLI.


function get_current_image_tag() { 
    if [ -z $1 ] | [ -z $2 ]; then
        echo "Arguments are ECS Clustername followed by AWS Region Name."
        echo "Example: get_current_image_tag mycluster eu-west-1"
        exit 1
    fi
    clustername=$1
    region=$2
    runningTasks=$(aws ecs list-tasks --cluster $clustername --region $region | ./jq.dms ".taskArns[0]" --raw-output)
    if [ -z $runningTasks ]; then
        echo "ERROR: Could not get ECS task list."
        exit 1
    fi
    currentTaskDef=$(aws ecs describe-tasks --tasks $runningTasks --cluster $clustername --region $region| ./jq.dms ".tasks[] | select( .lastStatus == \"RUNNING\") | .taskDefinitionArn" --raw-output)
    if [ -z $currentTaskDef ]; then
        echo "ERROR: No Running Task, full deployment with build required."
        exit 1
    fi
    currentImage=$(aws ecs describe-task-definition --task-definition $currentTaskDef --region $region | ./jq.dms ".taskDefinition.containerDefinitions[0].image" --raw-output)
    echo "$currentImage"
    if [ -z $currentImage ]; then
        echo "ERROR: Could not get running image tag."
        exit 1
    else
        imageTag=$(echo "$currentImage" | grep -oe "[\^:][A-Za-z0-9._%+-].*$")
        #line below removes the colon in the image name, by removing the first character.
        imageTag=${imageTag#?}
        echo "$imageTag"
    fi
}
