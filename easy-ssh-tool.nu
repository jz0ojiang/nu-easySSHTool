module easySSHTool {
  
  # Basic Connection Parameters
  # -1       Use SSH protocol version 1 (deprecated, use version 2 instead).
  # -2       Use SSH protocol version 2 (default).
  # -4       Force IPv4 usage.
  # -6       Force IPv6 usage.
  # -A       Enable forwarding of the authentication agent connection.
  # -a       Disable forwarding of the authentication agent connection.
  # -C       Enable compression to improve performance over low-bandwidth networks.
  # -f       Run SSH in the background after authentication.
  # -N       Do not execute remote commands, often used with port forwarding.
  # -q       Quiet mode, suppresses warning messages.
  # -V       Display the SSH version and exit.

  # User and Host Configuration
  # -p [port]        Specify the port number to connect to, default is 22.
  # -l [user]        Specify the login username.
  # -i [identity_file] Specify the private key file for authentication.
  # -F [config_file] Specify an alternative SSH configuration file instead of ~/.ssh/config.
  # -t               Force pseudo-terminal allocation, useful for remote interactive commands.
  # -T               Disable pseudo-terminal allocation.

  # Authentication and Encryption Options
  # -o [option]      Override specific configuration options in ssh_config. Examples:
  #                  -o StrictHostKeyChecking=no  Skip host key checking.
  #                  -o UserKnownHostsFile=/dev/null Avoid saving known hosts file.
  #                  -o PasswordAuthentication=yes|no Enable or disable password authentication.
  # -X               Enable X11 forwarding, allowing remote graphical applications to display locally.
  # -Y               Enable trusted X11 forwarding (use with caution in untrusted environments).
  # -K               Disable GSSAPI authentication.
  # -k               Do not automatically forward GSSAPI credentials.

  # Debugging and Logging
  # -v               Verbose mode (one -v for basic, -vv for more, -vvv for highest detail).
  # -E [log_file]    Specify a log file for SSH messages.

  # Port Forwarding
  # -L [local_port:remote_host:remote_port] Local port forwarding (forwarding local port to remote).
  # -R [remote_port:local_host:local_port] Remote port forwarding (forwarding remote port to local).
  # -D [local_port]  Dynamic port forwarding to create a SOCKS proxy.

  # Security Options
  # -M               Enable master mode for control connections, allowing session multiplexing.
  # -S [ctl_path]    Specify control socket path for session multiplexing.
  # -n               Prevent reading from stdin, useful for running in the background.

  # Additional Options
  # -B [bind_address] Bind to specified local address on the client side.
  # -b [bind_interface] Bind to a specified network interface.
  # -c [cipher_spec] Specify cipher to use for encryption.
  # -Q [query_option] Query supported features such as ciphers or mac algorithms.


  # servers.json example
  # [
  #     "name": {
  #         "host": "example.com",
  #         "port?": 22,
  #         "user?": "username",
  #         "identity_file?": "~/.ssh/id_rsa",
  #         "options?": [
  #             "-v",
  #             "-o StrictHostKeyChecking=no",
  #             "-o UserKnownHostsFile=/dev/null"
  #         ]
  #     }
  # ]

  const config = {
      "server_list": "~/.ssh/servers.json",
      "pems_dir": "~/.ssh/pems/",
      "default_identity_file": "~/.ssh/id_rsa",
      "safemode": true,
      "ignore_warning": false
  }

  export def validate_config [] {
      if not ($config.server_list | path exists) {
        #   error make {
        #       msg: $"Server list file not exists: ($config.server_list)",
        #       label: {
        #           text: "server_list file not exists",
        #           span: (metadata $config).span
        #       }
        #   }
        {} | save ($config.server_list | path expand)
      }
      if not ($config.pems_dir | path exists) {
          error make {
              msg: $"PEM directory not exists: ($config.pems_dir)",
              label: {
                  text: "pems_dir not exists",
                  span: (metadata $config).span
              }
          }
      }
      if not ($config.default_identity_file | path exists) {
          error make {
              msg: $"Default identity file not exists: ($config.default_identity_file)",
              label: {
                  text: "default_identity_file not exists",
                  span: (metadata $config).span
              }
          }
      }
      if not ($config.safemode or $config.ignore_warning) {
          print $"(ansi red_bold)[Warning](ansi reset) EasySSHTool: Safe mode is disabled. This may expose sensitive information."
      }
  }
      
  def servers [] { open ($config.server_list | path expand) }

  def helper [] {
      [
          { value: "list", description: "列出所有服务器信息"},
          { value: "connect", description: "连接到服务器" },
          { value: "config", description: "打开 servers.json" },
          { value: "add", description: "新增服务器" },
          { value: "remove", description: "移除服务器" },
          ...( servers | columns | each {|it|
              {
                  value: $it,
                  description: $"Connect to (ansi yellow)(servers | get $it | get name)(ansi reset)"
              }
          })
        ] 
  }

  def sub_helper [context: string] {
      match ($context | split words | last) {
          "connect" => { servers | columns }
          "add" => {
              [{ description: "服务器关键字" }, { description: $"已使用关键字: (ansi red)(servers | columns | str join ' ')(ansi reset)"}]
          }
      } 
  }

  def command_helper [context: string] {
      if ($context | split words | last 2 | first) == "add" {
          if ($context | split words | last) in (servers | columns) {
              [{ description: $"(ansi red_bold)该关键字已被使用: ($context | split words | last)(ansi reset)" }, {}]
          } else {
              [{ value: "\"ssh username@host\"", description: "ssh command" }, {}]
          }
      }
  }
      
  def name_helper [context: string] {
      [{ value: "display_name", description: "服务器名称" }, {}]
  }

  def description_helper [context: string] {
      [{ value: "description", description: "设置备注" }, {}]
  }

  def covered [] {
      # usr@addr => ***@***
      $in | into string | str replace --regex ".*@" "***@" | str replace --regex --all "[^@]" "*"
  }

  def has-flag [flag: string] {
      # $in | columns | any {|it| $it == $flag and $in.$it | is-not-empty }
      $in | get --ignore-errors $flag | is-not-empty
  }

  def parse-path [] {
      let path = $in | into string
      if ($path =~ "^/.*" or $path =~ "[A-Z]+:.*?$") {
          # check if path is absolute
          if ($path | path exists) { $path }
      } else if ($path =~ "^[a-zA-Z0-9_\\-\\.]+$") { 
          # check if path is only filename
          let fullpath = ( $config.pems_dir ++ / ++ $path | path expand )
          if ($fullpath | path exists) { $fullpath }
      } else {
          $path | path expand
      }
      $config.default_identity_file
  }

  def build [target: record] {
      if not ($target | has-flag host) {
          error make {
              msg: $"Missing host in (if ($target | has-flag name) { $target.name } else { $target })",
              label: {
                  text: "missing host",
                  span: (metadata $target).span
              }
          }
      }


      return {
          nu -c ([
          $"ssh ",
          $"(if ($target | has-flag port) { 
              '-p ' ++ ($target.port | into string) 
          })",
          $"(if ($target | has-flag identity_file) { 
              '-i ' ++ ($target.identity_file | parse-path) 
          })",
          $"(if ($target | has-flag options) { 
              $target.options | str join ' ' 
          })",
          $"($target | get --ignore-errors user)@($target | get --ignore-errors host)"
          ] | str join " " | str replace -r "\\s+" " ")
      }
  }

  def connect [keyword: string, --span] {
      if $keyword in (servers | columns) {
          do (build (servers | get $keyword))
      } else {
          error make {
              msg: $"No server found with name ($keyword)",
              label: {
                  text: "not found",
                  span: $span
              }
          }
      }
  }

  def match_or_default [input, pattern, field, default_value] {
      let result = $input | parse -r $pattern | get $field
      $result | get --ignore-errors 0 | default $default_value
  }

  def extract_flags [] {
      let regex = "(?P<item>(?:[^\\s\"']+|\"[^\"]*\"|'[^']*'|--[^\\s=]+=([^\\s\"']+|\"[^\"]*\"|'[^']*'))+)"
      let all_flags = $in | parse -r $regex | each {values | first} | enumerate | skip 1
      $all_flags | each {|it|
          let prev = if ($it.index - 2 <= 0) { null } else {$all_flags | get ($it.index - 2)}
          let next = if ($it.index == ($all_flags | length)) { null } else {$all_flags | get ($it.index)}

          if ($it.item =~ "^-") {
              if ($next == null) {
                  return $it.item
              }
              if ($next.item !~ "^-") {
                  $it.item ++ " " ++ $next.item
              } else {
                  $it.item
              }
          } else {
              null
          }
      }
  }

  def record_remove_null [] {
      $in | reject ...($in | transpose k v | each {|it| if ($it.v | is-empty) { $it.k } })
  }

  def parse_ssh [] {
      let cmd = $in | into string
      $cmd | each {|it|
          # 提取 host
          let host = match_or_default $it '(?:@)?(?P<host>([a-zA-Z0-9._-]+\.[a-zA-Z]{2,}|localhost|[0-9]{1,3}(\.[0-9]{1,3}){3}|\[[0-9a-fA-F:]+\]|::1))' 'host' null

          # 提取 user，优先从 -l 参数，否则尝试从 user@host 中提取
          let user = match_or_default $it '-l (?P<user>\S+)' 'user' (
              match_or_default $it '(?P<user>[a-zA-Z0-9._-]+)@' 'user' null
          )

          # 提取 port
          let port = match_or_default $it '-p (?P<port>\d+)' 'port' null | do { if ($in != null) {$in | into int} }

          # 提取 identity_file
          let identity_file = match_or_default $it '-i (?P<identity_file>\S+)' 'identity_file' null

          # 提取所有 options
          let options = (
                                  $it | 
                                  extract_flags | 
                                  each {|it| if ($it !~ '^(-p \d|-i \S|-l \S)') { $it } } | 
                                  compact | 
                                  do {if ($in | is-empty) {null} else {$in}}
                              )

          {
              host: $host,
              port: $port,
              user: $user,
              identity_file: $identity_file,
              options: $options
          }
      }
  }

  def table_default [default] {
      let table = $in
      $table | each {|row|
          $table | columns | reduce -f {} {|it, acc|
              $acc | insert $it ($row | get --ignore-errors $it | default $default)
          }
      }
  }
  
  def cmd_list [--unsafe(-u) = (not $config.safemode)] {
      servers | transpose k v | each {|it|
          if ($unsafe) {
              { keyword: $it.k, ...$it.v }
          } else {
              { keyword: $it.k, ...$it.v } | update host {|v| $it.v.host | covered } | update user {|v| "***" }
          }
      } | table_default "N/A"
  }

  def cmd_config [] {
      start ($config.server_list | path expand)
  }

  def cmd_add [
      span,
      keyword: any = null,
      command: any = null, 
      name?,
      desc? = ""
  ] {
      if ($command | is-empty) or ($keyword | is-empty) {
          print "Usage: easy-ssh-tool add <keyword> <command> [name] [desc]"
          return
      }
      if $keyword in (servers | columns) {
          error make {
              msg: "Keyword already exists",
              label: {
                  text: "already exists",
                  span: $span
              }
          }
      }
      if $keyword in ["list", "add", "remove", "config", "connect", "help"] {
          error make {
              msg: "Keyword is reserved",
              label: {
                  text: "reserved keyword",
                  span: $span
              }
          }
      }
      let server = {
          command: $command,
          keyword: $keyword,
          name: (if ($name | is-empty) { $keyword } else { $name | into string })
      }
      servers | upsert $keyword ({name: $server.name, ...($server.command | parse_ssh), desc: $desc} | record_remove_null) | save ($config.server_list | path expand) -f
      print $"Added server: ($name) with keyword: ($keyword)"
      [[keyword name];[$keyword $server.name]] | merge [($server.command | parse_ssh)] | update cells {|v| $v | default "N/A" }
      # [[Keyword Name];[$keyword $server.name]]
      # $server.command | parse_ssh
  }
  
  def cmd_remove [
      keyword: any = null, 
  ] {
      if ($keyword | is-empty) {
          print "Usage: easy-ssh-tool remove <keyword>"
          return
      }
      servers | reject $keyword | save ($config.server_list | path expand) -f
  }
  
  def cmd_desc [
      keyword: any = null,
      description: string = ""
  ] {
      if ($keyword | is-empty) {
          print "Usage: easy-ssh-tool desc <keyword> [description]"
          return
      }
      let conf = servers | get $keyword
      if ($conf | is-empty) {
          error make {
              msg: "Keyword not found",
              label: {
                  text: "not found",
                  span: (metadata $keyword).span
              }
          }
      }
      servers | upsert $keyword ($conf | upsert desc $description) | save ($config.server_list | path expand) -f
      print $"Updated description for ($keyword)"
  }

  export def "easy-ssh-tool" [
      action = "list": string@helper # action (list|add|remove|connect|config) or connect to server
      server?: string@sub_helper # server keyword
      command?: string@command_helper # ssh command
      name?: string@name_helper # server name
      description?: string@description_helper # server description
      --unsafe(-u) # disable safemode or not, default is false (follow config)
      ...args
  ] {
      validate_config
      def IMPLY [it: bool] { (not $in) or $it }
      let u = $config.safemode | IMPLY $unsafe
      let argv = $args | append [null, null]
      match $action {
          "list" => { cmd_list --unsafe=$u }
          "add" => { cmd_add (metadata $server).span $server $command $name }
          "remove" => { cmd_remove $server }
          "desc" => { cmd_desc $server $command } # $command here is description
          "config" => { cmd_config }
          "connect" => { connect $server --span=(metadata $action).span }
          "help" => { est --help }
          _ => { connect $action --span=(metadata $action).span }
      }
  }   
}

use easySSHTool easy-ssh-tool
alias est = easy-ssh-tool