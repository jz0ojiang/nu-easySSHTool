# easySSHTool

README | [简体中文](README.zh-CN.md)

`easySSHTool` is an SSH management tool based on [Nushell](https://www.nushell.sh/), designed specifically for managing SSH connections in multi-server environments. It provides formatted output, secure mode, quick server import, and other features to make SSH configuration and connections more convenient, especially for users with specific SSH management needs.

## Features

- **Configuration Validation**: Automatically checks configuration paths (such as server list and private key files) to ensure the environment is correctly set up.
- **Secure Mode**: Hides sensitive information (like `host` and `username`), making it safe to use in public environments.
- **Formatted Output**: All output content is neatly formatted to Nushell's standards, ensuring clear and organized display.
- **Quick Server Import**: Supports importing server configurations by directly pasting SSH commands.
- **Tab Completion**: Provides basic validation and tab completion, making command input smoother.

## Configuration

`easySSHTool` allows users to customize the following configuration items:

- **server_list**: Specifies the path to the server list file, with the default value set to `~/.ssh/servers.json`.
- **pems_dir**: Specifies the storage path for PEM key files, defaulting to `~/.ssh/pems/`.
- **default_identity_file**: The default identity file path, used as a fallback if no private key is specified, with a default of `~/.ssh/id_rsa`.
- **safemode**: Toggles secure mode, which is enabled by default. In secure mode, `host` and `username` are masked, but this can be temporarily disabled using the `--unsafe` option.

You can adjust these paths and options in the `config` according to your needs.

## Installation

1. **Clone the repository**:
   
   ```bash
   git clone https://github.com/jz0ojiang/easySSHTool.git
   ```

2. **Load the module in the Nushell configuration file**:
   Open the Nushell configuration file and add the following:
   
   ```bash
   source path/to/easySSHTool/easySSHTool.nu
   ```

3. **Initial Setup**:
   On the first run, the tool will automatically create a server configuration file at `~/.ssh/servers.json` (default path for `server_list` in `config`).

## Usage

### List Servers

List all configured servers:

```bash
est list
```

### Connect to a Server

Connect to a server using its specified keyword:

```bash
est connect example_keyword
```

### Add and Remove Servers

- **Add a server** (supports direct SSH command import):
  
  ```bash
  est add example_keyword "ssh username@newhost.com"
  ```

- **Remove a server**:
  
  ```bash
  est remove example_keyword
  ```

### Using Secure Mode

Secure mode is enabled by default to hide sensitive information. To temporarily disable it, use the `--unsafe(-u)` option:

```bash
est -u list
```

## Future Plans

Future enhancements include support for synchronizing with the `.ssh/config` file and a possible Go-based refactoring to improve cross-platform performance and efficiency.

## Contributing

We welcome suggestions and contributions to `easySSHTool`! Here’s how to get started:

1. **Fork the repository and clone it locally**.

2. **Create a feature branch**:
   
   ```bash
   git checkout -b feature_branch
   ```

3. **Commit and push your changes**:
   
   ```bash
   git commit -m "Add new feature"
   git push origin feature_branch
   ```

4. **Create a Pull Request**.

Thank you for your support and contributions! 😊
