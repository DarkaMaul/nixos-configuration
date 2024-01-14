let
  lyretail = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDtQFica1N9fXu1qEMnPh5LJOmIikWIcXOypTjK39f8s";
in {
  "restic-password.age".publicKeys = [ lyretail ];
  "restic-env.age".publicKeys = [ lyretail ];
}