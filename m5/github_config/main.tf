resource "github_repository" "main" {
  name        = var.repository_name
  description = "Terraform Deep Dive Repository for Globomantics Networking"
  visibility  = "public"
  auto_init   = true
  gitignore_template = "Terraform"
}

resource "github_branch" "main" {
  repository = github_repository.main.name
  branch     = "main"
}

resource "github_branch_default" "default" {
  repository = github_repository.main.name
  branch     = github_branch.main.branch
}