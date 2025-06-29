let
  jqwang = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN+VXTehNqZod7c/B+dW8Ky2B946nG0ud9zyzEue7LUr";
  users = [ jqwang ];

  # Normally you would add the host's pub keys here.
  systems = [ ];
in
{
  "github-nix-ci/jiaqiwang969.token.age".publicKeys = users ++ systems;
}
