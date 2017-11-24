param(
    $TerraformVarsFile = "..\..\terraform.tfvars"
)
#Get the AWS keys
$content = Get-Content $TerraformVarsFile
$values = @{}
foreach($line in $content){ 
    if($line){
        $values.Add($line.Split(' ')[0],$line.Split(' ')[2])
    }
}

#Install the AWS PowerShell if you don't already have it
if(-not (Get-Module AWSPowerShell -ErrorAction SilentlyContinue)){
    Install-Module AWSPowerShell -Force
}

#Set the AWS Credentials
Set-AWSCredential -SecretKey $values.aws_secret_key.Replace('"','') -AccessKey $values.aws_access_key.Replace('"','')

#Set the default region as applicable
$region = "us-west-2"
Set-DefaultAWSRegion -Region $region

#Create a new S3 bucket
New-S3Bucket -BucketName "ddtbucket" -CannedACLName    


