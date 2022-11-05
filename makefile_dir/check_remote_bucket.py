import boto3
import sys

# Let's use Amazon S3
s3 = boto3.resource('s3')

# Print out bucket names
for bucket in s3.buckets.all():
    if bucket.name == "acme-storage-robertoasir":
        print("\nSUCCESS: Check remote bucket ok\n")
        sys.exit(0)

print("\nERROR: Remote bucket is not accesible\n")
sys.exit(1)
