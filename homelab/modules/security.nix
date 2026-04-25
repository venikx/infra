{ lib, ... }:

{
  boot.kernelModules = [ "tcp_bbr" ];

  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.core.default_qdisc" = "fq";

    # anti-spoofing
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    #"net.ipv4.conf.all.log_martians" = 1;
    #"net.ipv4.conf.default.log_martians" = 1;

    # SYN flood protection
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_max_syn_backlog" = 4096;
    "net.ipv4.tcp_synack_retries" = 3;
    "net.ipv4.tcp_syn_retries" = 5;

    # ICMP hardening
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    "net.ipv4.icmp_echo_ignore_all" = 0;

    # disable ICMP redirects
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv6.conf.all.send_redirects" = 0;
    "net.ipv6.conf.default.send_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv6.conf.all.secure_redirects" = 0;
    "net.ipv6.conf.default.secure_redirects" = 0;

    # disable source routing
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;

    # tcp connection security
    "net.ipv4.tcp_rfc1337" = 1;
    "net.ipv4.tcp_challenge_ack_limit" = 1000;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  networking.firewall = {
    enable = true;
    allowPing = false;
  };

  services.avahi.enable = false;
  services.printing.enable = false;
  services.fail2ban.enable = lib.mkDefault true;
}
