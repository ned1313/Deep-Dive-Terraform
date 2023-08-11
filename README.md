# Deep-Dive-Terraform

Welcome to Terraform - Deep Dive version 3.  These exercise files are meant to accompany my course on [Pluralsight](https://app.pluralsight.com/library/courses/terraform-deep-dive-2023).  The course was developed using version 1.5.x of Terraform.

If you're looking for the older versions of the course, that is still available on the v1 and v2 branches. I am no longer maintaining them, but I thought I would keep them around for posterity or if you're already working through those versions of the course.

## AWS Account

You are going to need an account where you have FullAdmin permissions. You are going to be creating policies, roles, profiles, VPCs, etc. If you don't have enough permissions in your current environment, then I recommend creating a temporary account to mess around in. In fact, probably do that regardless. You don't want to accidentally mess something up at work because you were trying to learn about Terraform.

You may exceed your EIP address quota when deploying multiple enviornments. You can request an increase through the AWS console in the Services Quotas area, under the Amazon Elastic Compute Cloud category. I recommend setting it to 15 just to be safe. It should be approved almost immediately, but may take 30 minutes to apply. So if you do it now, it should be ready long before you get to that portion of the course.

## Using the files

Each folder represents a module from the course and they all build off of each other. You will be creating two working directories in your local copy of the exercise files: `network_config` and `application_config`. Both of these folders are part of the `.gitignore` so they will not be committed back to the repository.

In the module folders, I have included Terraform configurations to help set up the necessary prerequisites. I've also included the commands you should run if you're following along. You don't have to run them verbatim, and I encourage you to mess around and try out different flags and commands.  If you run into an issue, please submit it as such and I will do my best to remediate it.

## Line Endings

An issue I have discovered from time to time is that Terraform doesn't much like the Windows style of ending a line with both a Carriage Return (CR) and a Line Feed (LF), commonly referred to as CRLF.  If you are experiencing strange parsing issues, change the line ending to be Line Feed (LF) only.  In VS Code this can be down by clicking on the CRLF in the lower right corner and changing it to LF.

## MONEY!!!

A gentle reminder about cost.  The course will have you creating resources in AWS.  Some of the resources are not going to be 100% free.  In most cases I have tried to use the [Free-tier](https://aws.amazon.com/free/) when possible, but AWS is about to start charging for IPv4 addresses even when they're attached to a resource. I'm not sure how this will impact the free tier, so just be cognizant of what you're creating.

When you complete an exercise in the course, you can always run `terraform destroy` and approve the destruction to remove all resources from AWS. Once you get to the application deployment, you will need to leave the networking in place for a successful application deployment. If you wish to tear things down, destroy the application first and then the network.

## Terraform Cloud and GitHub Actions

Previous versions of this course used Docker, Consul, and Jenkins to provide remote state and CI/CD operations. This ended up being a sticking point for several people, and they ended up abandoning the course. To simplify things, I have replaced those technologies with Terraform Cloud and GitHub Actions. This is not an overt endorsement of either technology, there are plenty of other great options when it comes to remote state storage and CI/CD for IaC. I chose GitHub Actions because we are already using GitHub any way, and I chose Terraform Cloud because it has a solid free tier and it is part of the Terraform Associate certification. Speaking of which...

## Certification

HashiCorp has released the *Terraform Certified Associate* certification.  You might be wondering if this course fully prepares you for the cert.  **It does not.**  Taking this course along with the [Terraform - Getting Started](https://app.pluralsight.com/library/courses/terraform-getting-started-2023) course on Pluralsight will meet all of the learning objectives for the certification, but there is no substitute for running the software on your own and hacking away.

I have coauthored a certification guide with Adin Ermie which you can find on [Leanpub](https://leanpub.com/terraform-certified/).  This is an unofficial guide, but I believe in concert with the Pluralsight courses you will be in a good position to sit the exam.

## Conclusion

I hope you enjoy taking this course as much as I did creating it.  I'd love to hear feedback and suggestions for revisions.

Thanks and happy automating!

Ned
