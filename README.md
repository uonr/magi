Magi
=========

```bash
git clone --recurse-submodules git@github.com:uonr/magi.git
cd magi
nix run github:serokell/deploy-rs .
```

Get a PGP Public key for your machine

```
ssh root@HOSTNAME "cat /etc/ssh/ssh_host_rsa_key" | nix-shell -p ssh-to-pgp --run "ssh-to-pgp -o secrets/keys/hosts/HOSTNAME.asc"
```
