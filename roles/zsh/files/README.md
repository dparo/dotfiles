# Order of sourcing for zsh shell

| FILE          | Interactive login (TTY, SSH) | Interactive non-login (prompt) | Script (zsh -c, scripts) |
| ------------- | ---------------------------- | ------------------------------ | ------------------------ |
| /etc/zshenv   | A                            | A                              | A                        |
| ~/.zshenv     | B                            | B                              | B                        |
| /etc/zprofile | C                            |                                |                          |
| ~/.zprofile   | D                            |                                |                          |
| /etc/zshrc    | E                            | C                              |                          |
| ~/.zshrc      | F                            | D                              |                          |
| /etc/zlogin   | G                            |                                |                          |
| ~/.zlogin     | H                            |                                |                          |

- So:

  - Scripts source only zshenv.
  - Interactive non-login shells source zshenv and zshrc.
  - Interactive login shells source zshenv, zprofile, zshrc, and zlogin.

- `bash` does not have a `script-mode` and lacks an equivalent to `zshenv`.

## Bash order of sourcing

|                  | Interactive login (TTY, SSH) | Interactive non-login (prompt) | Script (bash -c, scripts) |
| ---------------- | ---------------------------- | ------------------------------ | ------------------------- |
| /etc/profile     | A                            |                                |                           |
| /etc/bash.bashrc |                              | A                              |                           |
| ~/.bashrc        |                              | B                              |                           |
| ~/.bash_profile  | B1                           |                                |                           |
| ~/.bash_login    | B2                           |                                |                           |
| ~/.profile       | B3                           |                                |                           |
| BASH_ENV         |                              |                                | A                         |
| ~/.bash_logout   | C                            |                                |                           |

## Resources

- https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/
- https://www.reddit.com/r/zsh/comments/e882c4/what_is_the_difference_between_zshrc_and_zprofile/
- https://shreevatsa.wordpress.com/2008/03/30/zshbash-startup-files-loading-order-bashrc-zshrc-etc/
