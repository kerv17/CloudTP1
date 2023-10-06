################################
# Setup AWS CLI
################################
ACCESS_KEY="$1"
SECRET_KEY="$2"
TOKEN="$3"

export TF_VAR_access_key="$ACCESS_KEY"
export TF_VAR_secret_key="$SECRET_KEY"
export TF_VAR_token="$TOKEN"

################################
# Terraform Infra
################################
echo "Terraforming Infra..."

#git clone "https://github.com/kerv17/CloudTP1.git"

#cd CloudTP1
cd Terraform
terraform init
terraform apply -auto-approve

export url=$(terraform output --raw alb_dns_name)
export load_balancer=$(terraform output --raw load_balancer_arn_suffix)
export cluster1=$(terraform output --raw M4_group_arn_suffix)
export cluster2=$(terraform output --raw T2_group_arn_suffix)
cd ..
#cd ..

echo "Terraforming completed!"

################################
# Requests
################################

docker pull kerv17/terra-requests:latest

echo "Launching requests"
docker run -e url="$url" kerv17/terra-requests:latest
echo "Requests completed"


################################
# Clean
################################

cd Terraform
#terraform destroy -auto-approve
cd ..

unset TF_VAR_access_key
unset TF_VAR_secret_key
unset TF_VAR_token
