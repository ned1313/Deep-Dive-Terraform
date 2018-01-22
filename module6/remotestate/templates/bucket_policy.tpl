{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "ReadOnly",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${read_only_user_arn}"
            },
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::${s3_bucket}",
                "arn:aws:s3:::${s3_bucket}/*"
            ]
        },
        {
            "Sid": "FullAccess",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${full_access_user_arn}"
            },
            "Action": "s3:*",
            "Resource": [
                "arn:aws:s3:::${s3_bucket}",
                "arn:aws:s3:::${s3_bucket}/*"
            ]
        }
    ]
}