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
Install-Module AWSPowerShell -Force

#Set the AWS Credentials
Set-AWSCredential -SecretKey $values.aws_secret_key -AccessKey $values.aws_access_key

#Set the default region as applicable
$region = "us-west-2"
Set-DefaultAWSRegion -Region $region

#Get the VPC and AZs
$vpc = Get-EC2Vpc
$azs = Get-EC2AvailabilityZone

#Create two new subnets in the third AZ
$privateSubnet = New-EC2Subnet -AvailabilityZone $azs[2].ZoneName -CidrBlock "10.0.5.0/24" -VpcId $vpc.VpcId
$publicSubnet = New-EC2Subnet -AvailabilityZone $azs[2].ZoneName -CidrBlock "10.0.4.0/24" -VpcId $vpc.VpcId

#Get the Public route table for all public subnets and associate the new public subnet
$publicRouteTable = Get-EC2RouteTable -Filter @{ Name="tag:Name"; values="Terraform-public"} -Region $region
Register-EC2RouteTable -RouteTableId $publicRouteTable.RouteTableId -SubnetId $publicSubnet.SubnetId

#Create the elastic IP and NAT Gateway
$eip = New-EC2Address -Domain vpc
$ngw = New-EC2NatGateway -AllocationId $eip.AllocationId -SubnetId $publicSubnet.SubnetId

#Create a route table for the new private subnet and send traffic through the NAT Gateway
$privateRouteTable = New-EC2RouteTable -VpcId $vpc.VpcId
New-EC2Route -DestinationCidrBlock 0.0.0.0/0 -NatGatewayId $ngw.NatGateway.NatGatewayId -RouteTableId $privateRouteTablTrueuteTableId
Register-EC2RouteTable -RouteTableId $privateRouteTable.RouteTableId -SubnetId $privateSubnet.SubnetId


