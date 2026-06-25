{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.service.deltachat-server;
  stateDir = "/var/lib/deltachat";
  maildirBase = "${stateDir}/mail";
  wwwDir = "${stateDir}/www";
  doveauthSocket = "/run/doveauth/doveauth.socket";
  newEndpointPort = 8403;

  chatmaild = pkgs.callPackage ./chatmaild.nix {};

  python = pkgs.python3.withPackages (ps: [ps.qrcode ps.pillow]);

  # Tiny HTTP server for /new — generates random credentials and returns JSON.
  # doveauth will auto-create the account on first IMAP/SMTP login.
  newEndpointScript = pkgs.writeScript "deltachat-new-endpoint" ''
    #!${pkgs.python3}/bin/python3
    import http.server, json, random, string, os

    DOMAIN = "${cfg.domain}"
    PORT = ${toString newEndpointPort}

    def random_str(chars, length):
        return "".join(random.choices(chars, k=length))

    class Handler(http.server.BaseHTTPRequestHandler):
        def log_message(self, fmt, *args):
            pass
        def _new_account(self):
            username = random_str(string.ascii_lowercase + string.digits, 9)
            password = random_str(string.ascii_letters + string.digits, 12)
            email = f"{username}@{DOMAIN}"
            body = json.dumps({"email": email, "password": password}).encode()
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
        def do_GET(self):
            if self.path != "/new":
                self.send_response(404); self.end_headers(); return
            self._new_account()
        def do_POST(self):
            if self.path != "/new":
                self.send_response(404); self.end_headers(); return
            self._new_account()

    http.server.HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
  '';

  indexTemplate = ./deltachat-index.html;
  setupWwwScript = pkgs.writeScript "deltachat-setup-www" ''
    #!${python}/bin/python3
    import pathlib, qrcode

    www = pathlib.Path("${wwwDir}")
    www.mkdir(parents=True, exist_ok=True)

    domain = "${cfg.domain}"
    dcaccount_uri = f"DCACCOUNT:https://{domain}/new"
    qr_file = f"qr-chatmail-invite-{domain}.png"
    qr_png = www / qr_file

    img = qrcode.make(dcaccount_uri)
    img.save(str(qr_png))

    template = pathlib.Path("${indexTemplate}").read_text()
    html = (template
        .replace("{{DOMAIN}}", domain)
        .replace("{{QR_FILE}}", qr_file))
    (www / "index.html").write_text(html)
    print(f"Generated {qr_png} and {www / 'index.html'}")
  '';

  doveauthConf = pkgs.writeText "doveauth.conf" ''
    uri = proxy:${doveauthSocket}:auth
    iterate_disable = no
    iterate_prefix = userdb/
    default_pass_scheme = plain
    password_key = passdb/%Ew"%Eu
    user_key = userdb/%Eu
  '';

  chatmailIni = pkgs.writeText "chatmail.ini" ''
    [params]
    mail_domain = ${cfg.domain}
    mailboxes_dir = ${maildirBase}
    tls_external_cert_and_key = /var/lib/acme/${cfg.domain}/fullchain.pem /var/lib/acme/${cfg.domain}/key.pem
    max_message_size = ${toString cfg.maxMailSize}
    username_min_length = 3
    username_max_length = 64
    password_min_length = 9
    delete_mails_after = 20
    delete_inactive_users_after = 90
    iroh_relay =
  '';
in {
  options.service.deltachat-server = {
    enable = lib.mkEnableOption "DeltaChat chatmail relay server";

    domain = lib.mkOption {
      type = lib.types.str;
      description = "Mail domain (e.g. chat.example.com). Must have MX pointing here.";
    };

    smtpPort = lib.mkOption {
      type = lib.types.port;
      default = 587;
      description = "Submission port for outgoing mail.";
    };

    imapPort = lib.mkOption {
      type = lib.types.port;
      default = 993;
      description = "IMAPS port.";
    };

    maxMailSize = lib.mkOption {
      type = lib.types.int;
      default = 31457280;
      description = "Maximum message size in bytes.";
    };

    acmeEmail = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Email address for ACME certificate registration.";
    };
  };

  config = lib.mkIf cfg.enable {
    security.acme.acceptTerms = true;
    security.acme.defaults.email = cfg.acmeEmail;
    security.acme.certs.${cfg.domain} = {
      listenHTTP = "127.0.0.1:8402";
      group = "dovecot2";
    };

    users.users.postfix.extraGroups = ["dovecot2" "opendkim"];

    users.groups.dovecot = {};

    users.users.vmail = {
      isSystemUser = true;
      group = "vmail";
      extraGroups = ["dovecot2"];
      home = maildirBase;
      createHome = false;
    };
    users.groups.vmail = {};

    systemd.tmpfiles.rules = [
      "d ${stateDir}    0751 root  root  -"
      "d ${maildirBase} 0750 vmail vmail -"
      "d ${wwwDir}      0755 vmail vmail -"
    ];

    system.activationScripts.deltachat-www = {
      text = "${setupWwwScript}";
      deps = [];
    };

    systemd.services.doveauth = {
      description = "Dovecot authentication daemon (chatmail auto-account creation)";
      wantedBy = ["multi-user.target"];
      before = ["dovecot.service"];
      after = ["network.target"];
      serviceConfig = {
        ExecStart = "${chatmaild}/bin/doveauth ${doveauthSocket} ${chatmailIni}";
        User = "vmail";
        Group = "dovecot2";
        RuntimeDirectory = "doveauth";
        RuntimeDirectoryMode = "0750";
        Restart = "always";
        RestartSec = "5s";
      };
    };

    systemd.services.deltachat-new-endpoint = {
      description = "DeltaChat /new account creation endpoint";
      wantedBy = ["multi-user.target"];
      after = ["network.target"];
      serviceConfig = {
        ExecStart = newEndpointScript;
        User = "vmail";
        Group = "vmail";
        Restart = "always";
        RestartSec = "5s";
      };
    };

    services.postfix = {
      enable = true;

      enableSubmission = true;
      submissionOptions = {
        smtpd_tls_security_level = "encrypt";
        smtpd_sasl_auth_enable = "yes";
        smtpd_client_restrictions = "permit_sasl_authenticated,reject";
        milter_macro_daemon_name = "ORIGINATING";
      };

      settings.main = {
        myhostname = cfg.domain;
        mydomain = cfg.domain;
        myorigin = cfg.domain;
        mydestination = [cfg.domain "localhost"];

        smtpd_tls_cert_file = "/var/lib/acme/${cfg.domain}/fullchain.pem";
        smtpd_tls_key_file = "/var/lib/acme/${cfg.domain}/key.pem";
        smtpd_tls_security_level = "may";
        smtpd_tls_auth_only = "yes";
        smtpd_tls_protocols = "!SSLv2,!SSLv3,!TLSv1,!TLSv1.1";

        smtp_tls_security_level = "may";
        smtp_tls_protocols = "!SSLv2,!SSLv3,!TLSv1,!TLSv1.1";

        smtpd_sasl_type = "dovecot";
        smtpd_sasl_path = "private/auth";
        smtpd_sasl_auth_enable = "yes";
        smtpd_sasl_security_options = "noanonymous";

        smtpd_relay_restrictions = [
          "permit_mynetworks"
          "permit_sasl_authenticated"
          "reject_unauth_destination"
        ];

        mailbox_transport = "lmtp:unix:private/dovecot-lmtp";
        local_recipient_maps = "";

        message_size_limit = cfg.maxMailSize;
        maximal_queue_lifetime = "2d";
        bounce_queue_lifetime = "2d";

        disable_vrfy_command = "yes";
        smtpd_tls_loglevel = "0";
        smtp_tls_loglevel = "0";
        smtpd_delay_reject = "yes";
        notify_classes = "";

        # rate limits
        smtpd_client_message_rate_limit = "500";
        smtpd_client_recipient_rate_limit = "2000";
        anvil_rate_time_unit = "3600s";

        smtpd_milters = "local:/run/opendkim/opendkim.sock";
        non_smtpd_milters = "local:/run/opendkim/opendkim.sock";
        milter_default_action = "accept";
      };
    };

    services.dovecot2 = {
      enable = true;
      configFile = pkgs.writeText "dovecot.conf" ''
        protocols = imap lmtp

        default_internal_user = dovecot2
        default_login_user = dovenull

        log_path = syslog
        auth_verbose = no
        auth_debug = no
        login_log_format_elements = user=<%u> method=%m session=<%{session}>
        mail_log_prefix = ""

        ssl = required
        ssl_min_protocol = TLSv1.2
        ssl_cert = <${"/var/lib/acme/${cfg.domain}/fullchain.pem"}
        ssl_key = <${"/var/lib/acme/${cfg.domain}/key.pem"}

        mail_location = maildir:${maildirBase}/%u
        mail_uid = vmail
        mail_gid = vmail

        auth_mechanisms = plain login

        passdb {
          driver = dict
          args = ${doveauthConf}
        }

        userdb {
          driver = dict
          args = ${doveauthConf}
        }

        service auth {
          unix_listener /var/lib/postfix/queue/private/auth {
            mode = 0660
            user = postfix
            group = postfix
          }
        }

        service lmtp {
          unix_listener /var/lib/postfix/queue/private/dovecot-lmtp {
            mode = 0600
            user = postfix
            group = postfix
          }
        }

        protocol imap {
          imap_idle_notify_interval = 29 secs
          mail_max_userip_connections = 20
        }

        service stats {
          unix_listener stats-reader {
            group = dovecot2
            mode = 0660
          }
          unix_listener stats-writer {
            group = dovecot2
            mode = 0660
          }
        }

        namespace inbox {
          inbox = yes
          separator = /
          mailbox Drafts {
            special_use = \Drafts
            auto = subscribe
          }
          mailbox Sent {
            special_use = \Sent
            auto = subscribe
          }
          mailbox Trash {
            special_use = \Trash
            auto = subscribe
          }
          mailbox Junk {
            special_use = \Junk
            auto = subscribe
          }
          mailbox DeltaChat {
            auto = subscribe
          }
        }
      '';
    };

    services.opendkim = {
      enable = true;
      selector = "mail";
      domains = "csl:${cfg.domain}";
      keyPath = "/var/lib/opendkim/keys";
      settings.UMask = "007";
    };

    networking.firewall.allowedTCPPorts = [
      25
      cfg.smtpPort
      cfg.imapPort
    ];
  };
}
