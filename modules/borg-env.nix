{ keyPath }: {
  BORG_RSH = "ssh -o 'StrictHostKeyChecking=no' -o 'UserKnownHostsFile /dev/null' -i ${keyPath}";
  BORG_UNKNOWN_UNENCRYPTED_REPO_ACCESS_IS_OK = "yes";
  BORG_RELOCATED_REPO_ACCESS_IS_OK = "yes";
}
