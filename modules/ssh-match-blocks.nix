{
  koma = {
    hostname = "10.110.100.2";
    user = "mikan";
    extraOptions = let 
      gpgHome = "/Users/mikan/.gnupg";
      target = "/run/user/1000/gnupg";
    in {
      "RemoteForward ${target}/S.gpg-agent" = "${gpgHome}/S.gpg-agent";
      "RemoteForward ${target}/S.gpg-agent.ssh" = "${gpgHome}/S.gpg-agent.ssh";
    };
  };

  suiu = {
    hostname = "45.88.193.19";
    user = "root";
  };

  lime = {
    hostname = "10.110.1.1";
    user = "root";
  };

  usagi = {
    hostname = "45.88.193.129";
    user = "root";
  };

  same = {
    hostname = "104.198.93.96";
    user = "mikan";
  };

}
