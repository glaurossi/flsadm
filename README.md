# fl studio asio driver manager

a simple tool to install, update, or remove fl studio's asio drivers without having to install fl studio.

![ss](https://i.imgur.com/JwE6FDJ.png)

## quick start

easiest:
1. open powershell
2. run the command:
   ```powershell
   irm glaurossi.com/flsadm | iex
   ```

manually:

1. download the latest [release](https://github.com/glaurossi/flsadm/releases/latest)
2. run `fl studio asio driver manager.bat`
3. choose from:
   - install/update driver
   - uninstall driver
   - exit

## security

all included drivers have been verified:
- [ILWASAPI2ASIO.dll](https://www.virustotal.com/gui/file/44f0a3c58bb00566b0a854295de3d9f3ced0789c750a2b2feaeb7b7346af0ac5)
- [ILWASAPI2ASIO_x64.dll](https://www.virustotal.com/gui/file/2a01391f99015e290dd984dbac142f750cbbdc4c30adfe561449a512c0369b81)

## legal

- educational/testing purposes only
- drivers sourced from [fl studio demo v24.2.2.4597](https://www.image-line.com/fl-studio-download/)
- property of image-line

## license

licensed under [MIT License](LICENSE)
