all: terraform_init terraform_apply terraform_show python_environment python_check_bucket_exists final_output

terraform_init:
	terraform init

terraform_apply: 
	terraform apply -auto-approve

terraform_show:
	terraform state show aws_s3_bucket.acme-storage | grep acme-storage-robertoasir

python_environment:
	pip3 install boto3

python_check_bucket_exists:
	python3 makefile_dir/check_remote_bucket.py

final_output:
	echo "SUCCESS"

