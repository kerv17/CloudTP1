################################
# Setup AWS CLI
################################

export AWS_ACCESS_KEY_ID="ASIAXW6VCEQFR6EIRH6K"
export AWS_SECRET_ACCESS_KEY="QzBk8F4rgxRnd3289GaRc3BN7SaEocEQKMXIro8r"
export AWS_SESSION_TOKEN="FwoGZXIvYXdzEHAaDGSw2CessGzXvffKGCLMATRqHn3cHVPFjQe5ZX+TVhK2O8MbNEaciddguAceC3SxMzp4S4fB0I6dZQXqqaDwuETa6q0BaYNIpxqb/HGT5VOpf7qX5QCGL4ydgDsZwkgc06DdR1dqVeHPDayXwqWiwPaumCIbRYxhPVOD1pzzC5GaV0yqneR68c6rRxMt8klxUAN3cUF5kk1MNbHQKgRbeTpG1UvY+Mlzhf3K49qbSyl/MwCz74FwKQCSraszhbeM35YbLGm+i2BBckUBTtFr2s03GwAWLnxfegkTlyim/PyoBjItdRHrHKr4gTfqXVG7aHYHN9xB/LaiMEFqHrH4WcAtfmmQSa6SH0km8qClY2AP"

################################
# Terraform Infra
################################
echo "Terraforming Infra..."

git clone "https://github.com/kerv17/CloudTP1.git"

cd CloudTP1
cd Terraform
terraform init
terraform apply -auto-approve

export url=$(terraform output --raw alb_dns_name)
export load_balancer=$(terraform output --raw load_balancer_arn_suffix)
export cluster1=$(terraform output --raw M4_group_arn_suffix)
export cluster2=$(terraform output --raw T2_group_arn_suffix)
cd ..
cd ..

echo "Terraforming completed!"

################################
# Requests
################################

docker pull kerv17/terra-requests:latest

echo "Launching requests"
docker run -e url="$url" kerv17/terra-requests:latest
echo "Requests completed"

$SHELL