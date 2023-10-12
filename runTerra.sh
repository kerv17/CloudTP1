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
sleep 1m
echo "Launching requests"
docker run -e url="$url" kerv17/terra-requests:latest
echo "Requests completed"

################################
# Benchmarking
########################
########

docker pull kerv17/benchmark:latest
sleep 3m
echo "Launching benchmark"
docker run -e load_balancer="$load_balancer" -e cluster1="$cluster1" -e cluster2="$cluster2" -e ACCESS_KEY="$ACCESS_KEY" -e SECRET_KEY="$SECRET_KEY" -e TOKEN="$TOKEN" kerv17/benchmark:latest


################################
# Clean
################################

unset TF_VAR_access_key
unset TF_VAR_secret_key
unset TF_VAR_token
