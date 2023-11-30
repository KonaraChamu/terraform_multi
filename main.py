import sys
import subprocess

def create_github_repo(instance_count):
    try:
        # Run Terraform apply passing the repo_name as a variable
        subprocess.run(["terraform", "apply", "-auto-approve", "-var", f"instance_count={instance_count}"])
        print("GitHub repository creation successful!")
    except subprocess.CalledProcessError as e:
        print(f"Error creating GitHub repository: {e}")

if __name__ == "__main__":
    # Check if an argument is provided
    if len(sys.argv) != 2:
        print("Usage: python script_name.py repository_name")
        sys.exit(1)

    instance_count = sys.argv[1]
    create_github_repo(instance_count)