# Example Ansible-based setup for a 6th gen. Thinkpad X1 Carbon

## Summary

This repository contains an [Ansible][a] playbook and set of roles for
configuring a [Void Linux][v] installation on a 6th Gen. ThinkPad X1
Carbon laptop. It's extracted from my private `ansible_config` repo,
which I also use to configure several other systems. Hopefully it's
useful as an example of using Ansible to configure personal stuff,
and/or documentation for configuring Linux for this particular laptop.

Note that I don't cover installing Void itself -- I didn't really need
to do anything special to get things working, though. I had to disable
Secure Boot in the BIOS, used a USB flash drive to install, and had an
USB ethernet adapter on hand. That was about it. (It should be possible
to install over wifi, but I haven't tried.)

[v]: https://voidlinux.org/
[a]: https://www.ansible.com/


### What's Ansible?

Ansible is a configuration management tool, similar to Chef, Puppet, or
Salt. It reads info about how to configure system(s), then generates
scripts which connect over ssh and figure out whether anything needs to
change. Then, the scripts report back, and optionally make the changes.

Rather than saying "install this, then add this line to its config
file", the config is framed as "this should be present; the config file
should contain this line". That way, steps that have already completed
can be skipped, and small updates can be applied quickly.

Because Ansible is pushing scripts, rather than waiting for an agent on
every system to pull and apply updates, it scales down nicely to
personal use cases.

I wrote a couple blog posts about using Ansible at a previous job:

- https://spin.atomicobject.com/2015/02/21/ansible-git-directory/
- https://spin.atomicobject.com/2015/09/21/ansible-configuration-management-laptop/
- https://spin.atomicobject.com/2015/09/22/ansible-config-example/

While Ansible has had several interface changes since then (for example,
the `sudo` setting is now named `become`, and no longer specific to
`sudo`), it's usually pretty good about suggesting replacements for
deprecated keywords, and those posts should still be conceptually
accurate.


## Contents

- install some tools I use almost everywhere

- set up root and user cron directories (e.g. `~/bin/cron/hourly.d/`)
  crontab entries for them, and a script that runs any files in them

- install local incoming ssh keys

- install packages for Void man pages, logging, sshd, ntpd

- set the package mirror, console font, and timezone

- set the keyboard layout to Dvorak

- register ACPI event handlers for the laptop's mute, volume, and
  brightness buttons

- hardware-related configuration to enable Suspend (S3), adjust the CPU
  overtemp throttling, and install microcode updates

- setting up wifi (using `connmanctl`)

- install some language-independent development tools

- install and configure an x11 tiling window manager (spectrwm),
  launcher (dmenu), and a relatively minimal notification daemon (dunst)


Also several optional things, which are controlled by flags/options in
`host_vars`, and disabled by default:

- install a git repo as the user homedir (with dotfiles, etc.)

- install tooling for any of several programming languages I use: C,
  Clojure, Erlang, J, k (Kona), Lisp (SBCL), Lua, Scheme (Chez, Chicken), OCaml,
  Prolog (SWI), Python

- install audio/video players (mplayer, mpd, the Spotify client)

- install some games (nethack, Steam, Dwarf Fortress)

- install tools to mount an Android phone's filesystem over USB (note
  that you'll need to log in again for group changes to take effect)

There are a couple things that would normally be configured via dotfiles
in my git homedir -- I've put relevant files in `dotfiles/` instead.


## Setup Instructions

- Clone the repo.

- `cd` to the base directory of the checkout.

- Run `bin/bootstrap_void`, which will install a couple things using `su`,
  and enable sudo for the current user.

- Log out and log back in, so group changes take effect (allowing `sudo`).

- Because Void is a rolling release distro, you might need to update the
  system packages a couple times before it reaches a fixpoint.

  To update, run:

    $ sudo xbps-install -Su

  until it no longer asks about updating packages. 

- Optional: run `setup_ssh_key` to generate an ssh key and automatically
  add it to `install_ssh_keys.yml` in the `common` role. I use the same
  set of roles for other computers besides this laptop, so that way my
  ssh public keys automatically get added to `~/.ssh/authorized_keys` on
  the others.

- Run `bin/link_paths`, to symlink some Ansible config files in the repo
  to a subdir in `/etc`, where Ansible will look for them. This probably
  isn't a good idea in a production setting, but it's very convenient
  for personal use. (To see which files, look at the script.)

    $ bin/link_paths /etc/ansible

- Edit the hosts file to add the name of the laptop to _both_ the
  `[laptop]` and `[void]` groups. This informs Ansible that it should
  consider them in both groups, and use their corresponding settings
  in `group_vars/` (`all`, `laptop`, `void`).

- Optionally, create a host-specific config file under `host_vars`.
  This overrides the other settings from group vars.

- Run the Ansible playbook, using `ansible-playbook`:

    $ ansible-playbook -l ${LAPTOP_NAME} -K laptop.yml

This will prompt for the sudo password once, upfront, and then begin
installing stuff. (`-K` is `--ask-become-pass`, where "become" is
Ansible's wrapper for use `sudo`, `doas`, and similar tools).

(Note: Ansible will pipe messages through cowsay, once present.)

- Optionally, edit the host-specific config file in `host_vars`
  and re-run Ansible. Anything that's already done will be quickly
  skipped, but new settings will be applied, until it converges on
  the new configuration.


## Misc. Ansible Notes

Ansible functionality is grouped into modules, like `file`, `copy`,
`git`, `lineinfile`, and OS-specific packaging modules like `xbps`,
`apt`, and `openbsd_pkg`. `ansible-doc <modname>` will print interface
notes for a particular module, and `ansible-doc -l` will list the
available modules.

Rather than using several `.yml` files in the base directory, the
config is gathered into several subdirectories, called roles. For more
info, see the [Asible docs for 'role'][r].

[r]: https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html

If anything fails, then `ansible-playbook` can be re-run with a
`--start "task name"` argument to resume at a particular task,
and `--step` can be used to pause and prompt after each step.

`--list-tasks` will list all the tasks in the playbook.


## The Laptop

This laptop works really well with Linux. Suspend didn't work by
default, but that's fixed in `roles/laptop/tasks/hardware.yml`, and
everything else has been straightforward to set up.

I strongly prefer its keyboard to any of the newer Apple laptops'
keyboards (particularly the touchbar models), and it has a trackpoint &
three mouse buttons. It's noticeably lighter than a MacBook Pro, without
feeling fragile.

Various forums recommended disabling the external microSD / SIM card
port in BIOS. (Apparently it uses an unusually high amount of power when
idle, and the SIM card isn't supported anyway.) `powertop` can be used
to identify other things that are disproportionately impacting battery
life.

There's other info about hardware support at the
[Arch wiki](https://wiki.archlinux.org/index.php/Lenovo_ThinkPad_X1_Carbon_(Gen_6)).
