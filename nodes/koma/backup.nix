{ ... }: 
let
  borgRepos = "/state/borg";
  nodeKey = let
    keyPath = name: builtins.readFile ../../secrets/borg/${name}.pub;
  in {
    minecraft = keyPath "lime.minecraft";
    ioover_net = keyPath "lime.ioover.net";
    boluo = keyPath "lime.boluo.chat";
  };
in { 
  users.users.borg.home = borgRepos;

  services.borgbackup.repos = {
    minecraft = {
      authorizedKeys = [ nodeKey.minecraft ];
      quota = "32G";
      path = "${borgRepos}/minecraft";
    };
    ioover_net = {
      authorizedKeys = [ nodeKey.ioover_net ];
      quota = "1G";
      path = "${borgRepos}/ioover_net";
    };
    boluo = {
      authorizedKeys = [ nodeKey.boluo ];
      quota = "32G";
      path = "${borgRepos}/boluo";
    };
  };
}
