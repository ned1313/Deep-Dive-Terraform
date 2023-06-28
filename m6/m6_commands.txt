# Get your local repository up to date
cd network_config
git checkout main
git pull

# Create a new branch for adding the workspace tag and removing variable defaults
git checkout -b add-workspace-tag

# Make code changes
# Commit changes to branch
git add .
git commit -m "Add workspace tag and make variables required"

# Push changes to GitHub
git push --set-upstream origin add-workspace-tag

# Head over to GitHub for the rest of the workflow

# Push an empty commit
git commit --allow-empty -m "Trigger workflow"
git push
