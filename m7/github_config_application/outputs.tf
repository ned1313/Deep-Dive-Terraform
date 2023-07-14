output "remote_url" {
  value       = github_repository.main.http_clone_url
  description = "URL to use when adding remote to local git repo."
}