{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${s3_rw_bucket}",
                "arn:aws:s3:::${s3_rw_bucket}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::${s3_ro_bucket}",
                "arn:aws:s3:::${s3_ro_bucket}/*"
            ]
        },
                {
            "Effect": "Allow",
            "Action": ["dynamodb:*"],
            "Resource": [
                "${dynamodb_table_arn}"
            ]
        }
   ]
}