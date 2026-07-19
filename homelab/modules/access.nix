{ ... }:
{
  users.users.root = {
    password = null;
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMrmJK/0PYSO/Vz3iZwoJ3z6h5kzlXIqUmmWefwOLSewAAAAC3NzaDpnZW5lcmFs ssh:general"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIOLE7iwE61qZMuu9y5Z4FBVCdYE5IV3NcClJmXsLhyU3AAAAC3NzaDpnZW5lcmFs ssh:general"
    ];
  };
}
