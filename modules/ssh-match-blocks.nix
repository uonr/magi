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

  bifrost = {
    hostname = "103.117.100.87";
    user = "root";
  };
}
