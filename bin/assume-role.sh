#!/bin/bash -v
aws_sts_credentials="$(aws sts assume-role \
  --role-arn "$AWS_ASSUME_ROLE_ARN_HIGH_AUTHORITY" \
  --role-session-name "circleci-session" \
  --external-id "$EXTERNALID_HIGH_AUTHORITY" \
  --duration-seconds 3600 \
  --query "Credentials" \
  --output "json")"

cat <<EOT > "aws-env.sh"
export AWS_ACCESS_KEY_ID="$(echo $aws_sts_credentials | jq -r '.AccessKeyId')"
export AWS_SECRET_ACCESS_KEY="$(echo $aws_sts_credentials | jq -r '.SecretAccessKey')"
export AWS_SESSION_TOKEN="$(echo $aws_sts_credentials | jq -r '.SessionToken')"
EOT
