# Set the umask to hide you files on the server

To ensure that your files are only readable to you and not for others on the server you should set your unmask (default file/directory creation mode). For this put the following line into your `~/.bashrc`, `~/.zshrc` or `~/.bash_profile`.

```shell
umask 077
```

Explanataion [here](https://chat.openai.com/share/a0ceee91-ce0b-42cb-b7c5-cf483b5609e1)