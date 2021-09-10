# Deep-Dive-Terraform

Welcome to Terraform - Deep Dive version 2.  These exercise files are meant to accompany my course on [Pluralsight](https://app.pluralsight.com/library/courses/terraform-deep-dive/).  The course was developed using version 0.12.x of Terraform.  As far as I know there are no coming changes in 0.13 or newer that will significantly impact the validity of these exercise files.  But I also don't control all the plug-ins, providers, and modules used by the configurations. 

If you're looking for the older version of the course, that is still available on the v1 branch. I am no longer maintaining it, but I thought I would keep it around for posterity.

## AWS Account

You are going to need an account where you have FullAdmin permissions. You are going to be creating policies, roles, profiles, VPCs, etc. If you don't have enough permissions in your current environment, then I recommend creating a temporary account to mess around in. In fact, probably do that regardless. You don't want to accidentally mess something up at work because you were trying to learn about Terraform.

You may exceed your EIP address quota when deploying multiple enviornments. You can request an increase through the AWS console in the Services Quotas area, under the Amazon Elastic Compute Cloud category. I recommend setting it to 15 just to be safe. It should be approved almost immediately, but may take 30 minutes to apply. So if you do it now, it should be ready long before you get to that portion of the course.

## Using the files

Each folder represents a module from the course and they often build upon each other. Especially, the directory m4 that has the setup for Consul and stores it's data. In each module and subfolder there may be an example of the *tfvars* file that you use named *terraform.tfvars.example*.  Simply update the contents of the file and rename it *terraform.tfvars*.

Once you have updated and renamed the *tfvars* file(s), you can run the commands in the *name_commands.txt* file, where the *name* is the name of the module or folder. Be sure to follow the commands in order, and be cognizant of what directory is being used for each command.  Or you can just noodle around on the terraform CLI and see what you can discover/break.  If you run into an issue, please submit it as such and I will do my best to remediate it.

## Line Endings

An issue I have discovered from time to time is that Terraform doesn't much like the Windows style of ending a line with both a Carriage Return (CR) and a Line Feed (LF), commonly referred to as CRLF.  If you are experiencing strange parsing issues, change the line ending to be Line Feed (LF) only.  In VS Code this can be down by clicking on the CRLF in the lower right corner and changing it to LF.

## MONEY!!!

A gentle reminder about cost.  The course will have you creating resources in AWS.  Some of the resources are not going to be 100% free.  In most cases I have tried to use the [Free-tier](https://aws.amazon.com/free/) when possible, but in some cases I have elected to use a larger size EC2 instance to demonstrate the possibilities with multiple environments. Additionally, the NAT gateways created by the networking configurations in later modules are not free! They can run about $40 a piece for the month.

When you complete an exercise in the course, be sure to tear down the infrastructure. Just run `terraform destroy` and approve the destruction to remove all resources from AWS. You should remove infrastructure in the reverse order that it was deployed. Destroy folder `applications` then `networking`. You get the idea.

### Module 7

The contents of module 7 are all about troubleshooting Terraform. As a consequence, if you try and run the files as they are you will see lots of fun errors. That's the point! In the process of creating trouble, I discovered a bug with how the AWS `aws_iam_instance_profile` is created/destroyed. That bug might be fixed by the time you try the course, so you might not see the same behavior. The final example of making Terraform panic may also be fixed in newer versions of Terraform. For reference, here's the [issue](https://github.com/hashicorp/terraform/issues/25707) I found to create the crash. If it has been fixed and you still want to see Terraform *PANIC*, you can search the GitHub issues for a different example or use an older version of Terraform that doesn't have the fix.

### Module 8

A special note about module 8. The process has you deploy resources using Jenkins. In order to destroy the infrastructure, kick off a build and select *Cancel* during the approval stage. Cancelling the process will trigger a destruction of the environment. Don't use this process in real life, you'll end up with some very unhappy Ops folks.

## Certification

HashiCorp has released the *Terraform Certified Associate* certification.  You might be wondering if this course fully prepares you for the cert.  **It does not.**  Taking this course along with the [Terraform - Getting Started](https://app.pluralsight.com/library/courses/getting-started-terraform) course on Pluralsight will meet most of the learning objectives for the certification, but there is no substitute for running the software on your own and hacking away.

I have coauthored a certification guide which you can find on [Leanpub](https://leanpub.com/terraform-certified/).  This is an unofficial guide, but I believe in concert with the Pluralsight courses you will be in a good position to sit the exam.

## Conclusion

I hope you enjoy taking this course as much as I did creating it.  I'd love to hear feedback and suggestions for revisions.

Thanks and happy automating!

Ned
