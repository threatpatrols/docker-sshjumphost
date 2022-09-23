# sshjumphost
An awesome sshjumphost (bastion host) for easily accessing container backend networks.

The `sshjumphost` makes easy work of setting up containerized ssh-key based or 
user-ca-key based authentication ssh jumphosts.

By default, sshjumphost does not provide a login-shell since the intent is to __jump__ 
from the sshjumphost to another.  All TCP port forwarding and `-J` style jumphost 
functionality is possible without a shell.  You can still get a shell by setting 
the `SSH_SHELL` environment variable.

Example: establish a SOCKS proxy to your backend network
```commandline
user@computer ~/$ ssh -D 1080 username@awesome.company.net
#
# sshjumphost
# version: v2.1.1 (5c7597ea)
# documentation: https://github.com/threatpatrols/docker-sshjumphost
#
# NB: set the SSH_SHELL environment variable to enable a login-shell at the sshjumphost.
#
```

## Docker
```commandline
docker pull threatpatrols/sshjumphost
```
* https://hub.docker.com/r/threatpatrols/sshjumphost

---

## Docker-compose example

```dockerfile
version: "3"

services:

  externalhost01:
    # Description :
    #  - username adjusted to "awesome" rather than the default "sshjumphost"
    #  - ssh key(s) supplied via environment variable in this example externalhost01
    #  - mount /data/hostkeys to store the hostkeys so these remain persistent on restart
    #  - this host is attached to the "awesome_network" that the "internalhost01" is also attached to below

    image: threatpatrols/sshjumphost:latest
    restart: unless-stopped
    ports:
      - 22222:22/tcp
    volumes:
      - "hostkeys_externalhost01:/data/hostkeys"
    networks:
      - awesome_network
    environment:
      SSH_USERNAME: "awesome"  # NB: default = sshjumphost
      SSH_AUTHORIZED_KEYS: "sk-ecdsa-sha2-nistp256@openssh.com xxxxxxxxxxxxxxxxxxxxxxxxx"  # NB: use your ssh key(s) here

  internalhost01:
    # Description :
    #  - username here is also adjusted to "awesome" rather than the default "sshjumphost"
    #  - ssh key(s) supplied via volume mount in this example internalhost01, alternative would be to simply
    #    mount "/data/userkeys/authorized_keys" and not set SSH_AUTHORIZED_KEYS
    #  - mount /data/hostkeys to store the hostkeys so these remain persistent on restart
    #  - this host is also attached to the "awesome_network" which makes it reachable from the above externalhost01 host
    #  - this host has SSH_SHELL defined which hence provides the user with a shell for the sake of the example

    image: threatpatrols/sshjumphost:latest
    restart: unless-stopped
    volumes:
      - "hostkeys_internalhost01:/data/hostkeys"
      - "/home/awesome/.ssh/authorized_keys:/data/userkeys/awesome_authorized_keys:ro"
    networks:
      - awesome_network
    environment:
      SSH_USERNAME: "awesome"
      SSH_SHELL: "/bin/ash"  # NB: host is alpine, /bin/ash is the available shell
      SSH_AUTHORIZED_KEYS: "/data/userkeys/awesome_authorized_keys"  # NB: name of mount above

networks:
  awesome_network:

volumes:
  hostkeys_externalhost01:
  hostkeys_internalhost01:

```

Starting this docker-compose creates 2x docker-containers, where `externalhost01`
is reachable via localhost on tcp-22222 and `internalhost01` that is only reachable
via connectivity to the `awesome_network`

It is now possible to reach `internalhost01` by using the `-J` switch to jump 
through `externalhost01` located at 127.0.0.1:22222

Note in the example provided the `SSH_SHELL` has been set on the `internalhost01` 
which provides the shell prompt as shown below.
```commandline
user@computer ~/$ ssh -J 127.0.0.1:22222 internalhost01
The authenticity of host 'internalhost01 (<no hostip for proxy command>)' can't be established.
ED25519 key fingerprint is SHA256:eoCSPJQMzNcmTZcaE0ge3EL4XbmTW8Y0bGqTZZ0Byk8.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'internalhost01' (ED25519) to the list of known hosts.
#
# sshjumphost: refer to documentation
# https://hub.docker.com/r/threatpatrols/sshjumphost
#
# NB: set the SSH_SHELL environment variable to enable a login-shell at the sshjumphost.
#
0bf40e5b195f:~$
```

The sshjumphost container also provides good visibility to STDOUT making it easy to
monitor via your container-environment logging etc.
```
dev-host01-1  | ssh-keygen: generating new host keys: RSA DSA ECDSA ED25519
dev-host01-1  | hostname: 0bf40e5b195f
dev-host01-1  | ip addr: inet 192.168.112.2/20 brd 192.168.127.255 scope global eth0
dev-host01-1  | username: awesome
dev-host01-1  | sshkey-fingerprints:
dev-host01-1  | 4096 SHA256:BjNltbmmfjBAF6/liSr+7NANEWzbyDvLJ6w7eTA928c (RSA)
dev-host01-1  | hostkey-fingerprints:
dev-host01-1  | 1024 SHA256:eXQcmDnDi2ydn+DAtLW0hGu9uXU5HTDKjNnrptyunFo root@0bf40e5b195f (DSA)
dev-host01-1  | 256 SHA256:8tIwmrhrK8+ZLw34B+OtVvOQe976d9mRByNpgnRR2FM root@0bf40e5b195f (ECDSA)
dev-host01-1  | 256 SHA256:eoCSPJQMzNcmTZcaE0ge3EL4XbmTW8Y0bGqTZZ0Byk8 root@0bf40e5b195f (ED25519)
dev-host01-1  | 3072 SHA256:cOue3Ig4hFIYWaHW1Xm3jv923+tkDAUeICw6Kk/R7gs root@0bf40e5b195f (RSA)
dev-host01-1  | sshd_command: /usr/sbin/sshd -D -e -4 -o PasswordAuthentication=no -o PermitEmptyPasswords=no -o PermitRootLogin=no -o AuthorizedKeysFile=/data/home/.ssh/authorized_keys -o HostKey=/data/hostkeys/ssh_host_dsa_key -o HostKey=/data/hostkeys/ssh_host_ecdsa_key -o HostKey=/data/hostkeys/ssh_host_ed25519_key -o HostKey=/data/hostkeys/ssh_host_rsa_key -o PubkeyAuthentication=yes -o GatewayPorts=no -o PermitTunnel=no -o X11Forwarding=no -o AllowTcpForwarding=yes -o AllowAgentForwarding=yes -o ListenAddress=0.0.0.0 -o Port=22 -o LogLevel=INFO
dev-host01-1  | Server listening on 0.0.0.0 port 22.
```

---

## Configuration ENV variables

### `SSH_USERNAME [<username>]`
* Default: `sshjumphost`

Change the username to suit your purposes.

### `SSH_AUTHORIZED_KEYS [<sshkey-value> | <filepath>]`
* Default: `/data/userkeys/authorized_keys`

Can be either the __actual__ ssh-key string-value -or- set as the pathname
to the volume-mounted public-key(s) if you mount the keys at a location other
than the default.

Recall that it is possible to set this value with more than one ssh-public 
key, using one key per line.

### `SSH_SHELL [<filename>]`
* Default: `/bin/dd`

By default, the sshjumphost user shell is set to `/bin/dd` that establishes a
session that does not terminate unless user-interrupted (eg CONTROL-C).  This hence
creates a sshjumphost cannot be repurposed for other usage beyond the intended 
__jumphost__ capability.

By setting the `SSH_SHELL` environment variable to `/bin/ash` it is possible to
gain a login-shell on the sshjumphost if required for some reason. 

### `SSHD_TRUSTED_USER_CA_KEYS [<cakey-value> | <filepath>]`
* Default: `/data/cakeys/trusted_keys`

Can be either the __actual__ ca-key string-value -or- set as the pathname
to the volume-mounted ca-key if you mount the key at a location other than
the default.

The associated `AuthorizedPrincipalsFile` is read from `/data/cakeys/authorized_principals` and
if this file does not already exist (eg via a volume-mount) then it is populated
with a single entry for the `SSH_USERNAME`

Using this mechanism it is possible to operate the sshjumphost in a way that 
accommodates multiple usernames authenticated through their individual user-keys 
that have been signed by the certificate authority.

### `SSHD_GATEWAY_PORTS [yes | no]`
* Default: `no`

Specifies whether remote hosts are allowed to connect to ports forwarded for the 
client (ie reverse tunneling)
* https://man.openbsd.org/sshd_config#GatewayPorts

### `SSHD_PERMIT_TUNNEL [yes | no]`
* Default: `no`

Specifies whether tun(4) device forwarding is allowed - NB: this is typically __not__ what you 
want if you are just looking for TCP port-forwarding.
* https://man.openbsd.org/sshd_config#PermitTunnel

### `SSHD_X11_FORWARDING [yes | no]`
* Default: `no`

Specifies whether X11 forwarding is permitted.
* https://man.openbsd.org/sshd_config#X11Forwarding

### `SSHD_ALLOW_TCP_FORWARDING [yes | no]`
* Default: `yes`

Specifies whether TCP forwarding is permitted.
* https://man.openbsd.org/sshd_config#AllowTcpForwarding

### `SSHD_ALLOW_AGENT_FORWARDING [yes | no]`
* Default: `yes`

Specifies whether ssh-agent forwarding is permitted.
* https://man.openbsd.org/sshd_config#AllowAgentForwarding

### `SSHD_LISTEN_ADDRESS [<ipv4-address>]`
* Default: `0.0.0.0`

Specifies the local addresses sshd(8) should listen on.
* https://man.openbsd.org/sshd_config#ListenAddress

### `SSHD_LISTEN_PORT [<port-number>]`
* Default: `22`

Specifies the TCP port number that sshd(8) listens on.
* https://man.openbsd.org/sshd_config#Port

### `SSHD_LOGLEVEL [<log-level>]`
* Default: `INFO`

Gives the verbosity level that is used when logging messages from sshd(8).
* https://man.openbsd.org/sshd_config#LogLevel

---

## Source
* https://github.com/threatpatrols/docker-sshjumphost

## Copyright
* Copyright (c) 2022 Nicholas de Jong <ndejong@threatpatrols.com>

## Thanks
This project originally forked from [binlab/docker-bastion](https://github.com/binlab/docker-bastion) and
mostly re-written top to bottom - thanks Mark for the initial base to work from.
