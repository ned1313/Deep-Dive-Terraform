# Deep-Dive-Terraform

Welcome to Terraform - Deep Dive.  These exercise files are meant to accompany my course on [Pluralsight](https://app.pluralsight.com/library/courses/deep-dive-terraform/).  The course was developed using version 0.11.x of Terraform.  The video clips are still using that version, but the exercise files have been updated to support version 0.12.x. As far as I know there are no coming changes that will significantly impact the validity of these exercise files.  But I also don't control all the plug-ins, providers, and modules used by the configurations. 

## AWS Account

You are going to need an account where you have FullAdmin permissions. You are going to be creating policies, roles, users, access keys, VPCs, etc. If you don't have enough permissions in your current environment, then I recommend creating a temporary account to mess around in. In fact, probably do that regardless. You don't want to accidentally mess something up at work because you were trying to learn about Terraform.

## Using the files

Each folder represents a module from the course and is completely self contained.  In each module and subfolder there will be an example of the *tfvars* file that you will use named *terraform.tfvars.example*.  Simply update the contents of the file and rename it *terraform.tfvars*.  Due to the sensitive nature of the information you place in the *tfvars* file, **do not** check it into source control, especially a public repository.  Some of us - *read me* - have made that mistake before and had to delete AWS access keys post-haste.

Once you have updated and renamed the *tfvars* file(s), you can run the commands in the *name_commands.txt* file, where the *name* is the name of the module or folder.  Be sure to run the commands from the same directory that the commands text file is located in.  Or you can just noodle around on the terraform CLI and see what you can discover/break.  If you run into an issue, please submit it as such and I will do my best to remediate it.

Aside from module 2, all the other modules include subfolders that are numbered in the order they should be run. In most cases this is to deploy the remote state location and set up prerequisites. Please note, the folder structure **will not** mirror what you see in the course. I have tried to reorganize things to make it easier to follow along with the concepts.

## AWS Key Pairs

One of the most common issues reported by people is confusion over AWS Key Pairs and Regions.  The Terraform configurations make use of us-east-1 (N. Virginia) as the default region.  You can override that region by changing the default or submitting a different value for `var.region`.  The AWS Key Pair you use must be created in the same region you have selected for deployment.  You can create those keys from either the AWS EC2 Console or the AWS CLI.  If you are using the CLI, the process is very simple.

```console
aws configure set region your_region_name
aws ec2 create-key-pair --key-name your_key_name
```

The json output will include a KeyMaterial section.  Copy and paste the contents of the KeyMaterial section starting with `-----BEGIN RSA PRIVATE KEY-----` and ending with `-----END RSA PRIVATE KEY-----` to a file with a .pem extension.  Then point the *tfvars* entry for `private_key_path` to the full path for the file.

If you are using Windows, remember that the file path backslashes need to be doubled, since the single backslash is the escape character for other special characters.  For instance, the path `C:\Users\Ned\mykey.pem` should be entered as `C:\\Users\\Ned\\mykey.pem`.

## Line Endings

Another issue I have discovered from time to time is that Terraform doesn't much like the Windows style of ending a line with both a Carriage Return (CR) and a Line Feed (LF), commonly referred to as CRLF.  If you are experiencing strange parsing issues, change the line ending to be Line Feed (LF) only.  In VS Code this can be down by clicking on the CRLF in the lower right corner and changing it to LF.

## MONEY!!!

A gentle reminder about cost.  The course will have you creating resources in AWS.  Some of the resources are not going to be 100% free.  In most cases I have tried to use the [Free-tier](https://aws.amazon.com/free/) when possible, but in some cases I have elected to use a larger size EC2 instance to demonstrate the possibilities with multiple environments. Additionally, the NAT gateways in the networking sections are not free! They can run about $40 a piece for the month.

When you complete an exercise in the course, be sure to tear down the infrastructure.  Each exercise file ends with `terraform destroy`.  Just run that command and approve the destruction to remove all resources from AWS. You should remove infrastructure in the reverse order that it was deployed. Destroy folder `5-applications`, then `4-networking`, then `2-lambda`. You get the idea.

### Module 5

A special note about module 5. The process has you deploy resources using Jenkins. In order to destroy the infrastructure, kick off a build and select *Cancel* during the approval stage. Cancelling the process with trigger a destruction of the environment. Don't use this process in real life, you'll end up with some very unhappy Ops folks.

## Certification

HashiCorp has released the *Terraform Certified Associate* certification.  You might be wondering if this course fully prepares you for the cert.  **It does not.**  Taking this course along with the [Terraform - Getting Started]((https://app.pluralsight.com/library/courses/terraform-getting-started) course on Pluralsight will meet most of the learning objectives for the certification, but there is no substitute for running the software on your own and hacking away.

I have coauthored a certification guide which you can find on [Leanpub](https://leanpub.com/terraform-certified/).  This is an unofficial guide, but I believe in concert with the Pluralsight courses you will be in a good position to sit the exam.

## Conclusion

I hope you enjoy taking this course as much as I did creating it.  I'd love to hear feedback and suggestions for revisions.

Thanks and happy automating!

Ned