# FL Studio ASIO Driver Manager
A simple tool to install, update, or remove FL Studio's ASIO drivers.

## Usage

### Easiest

1. Open Powershell
2. Run the command:

   ```
   irm glaurossi.com/flsadm | iex
   ```

### Manually

1. Download/extract the latest release [here](https://github.com/glaurossi/flsadm/releases/latest).
2. Run `FL Studio ASIO Driver Manager`
3. Select an option from the menu:
   - Install or update driver
   - Uninstall driver
   - Exit

## VT Scans

- [ILWASAPI2ASIO.dll](https://www.virustotal.com/gui/file/44f0a3c58bb00566b0a854295de3d9f3ced0789c750a2b2feaeb7b7346af0ac5)
- [ILWASAPI2ASIO_x64.dll](https://www.virustotal.com/gui/file/2a01391f99015e290dd984dbac142f750cbbdc4c30adfe561449a512c0369b81)

## Disclaimer

- This tool is provided for educational and testing purposes only.
- The ASIO drivers included were extracted from [**FL Studio Demo v24.2.2.4597**](https://www.image-line.com/fl-studio-download/) and are the property of Image-Line.

## Todo

- [ ] macOS version
- [x] `irm`
- [ ] `curl | bash`

## License

MIT License — see the [LICENSE](LICENSE) file for details.