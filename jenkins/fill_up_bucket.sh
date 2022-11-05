truncate -s 21M 21mb.txt
aws s3 cp 21mb.txt  s3://acme-storage-robertoasir/
rm 21mb.txt
