## Instructions for first boot on Armbian

1. Start your new machine
2. Find its IP address, maybe from your router
3. Log in via SSH:
   - `ssh root@<ip address>`
   - Password: `1234`
4. Armbian will make you change the root password, and create a non-root user account.
   - If you call the account '${user_acct}', these instructions will work as is. Otherwise you will need to adjust them for whatever username you choose.
   - Save the new root password in your password manager. Or your eidetic memory, I guess?
5. Authorize your public key to log on as the non-root user via SSH:

   ```sh
   mkdir -p /home/${user_acct}/.ssh
   echo '${public_key}' >> /home/${user_acct}/.ssh/authorized_keys
   chown ${user_acct}:${user_acct} /home/${user_acct}/.ssh/authorized_keys
   ```
7. Log out (Hit `Ctrl+D`, or run `exit`)

Congrats! Your host is now ready for `k3sup`.
