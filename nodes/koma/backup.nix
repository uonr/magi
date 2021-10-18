{ secrets, ... }: 
let
  borgRepos = "/state/borg";
  nodeKey = let
    keyPath = name: builtins.readFile "${secrets}/borg/${name}.pub";
  in {
    minecraft = keyPath "lime.minecraft";
    ioover_net = keyPath "lime.ioover.net";
    boluo = keyPath "lime.boluo.chat";
    play_trpg = keyPath "sage.play_trpg";
    mythal = keyPath "lime.mythal";
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
    play_trpg = {
      authorizedKeys = [ nodeKey.play_trpg ];
      quota = "4G";
      path = "${borgRepos}/play_trpg";
    };
    mythal = {
      authorizedKeys = [ nodeKey.mythal ];
      quota = "4G";
      path = "${borgRepos}/mythal";
    };
  };
}
