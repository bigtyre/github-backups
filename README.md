# github-backups

Shell script to create a backup of a set of code repositories hosts on GitHub. Change the GitHub API URL to select which organization or user you want to backup. Authentication is done by adding a file .token and .username to the folder you are running the backup from containing, respectively, a personal access token (PAT) and username to login to GitHub with. Authentication is only necessary if you want to include Private repositories in the backup.
