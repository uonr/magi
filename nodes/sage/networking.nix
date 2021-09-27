{ ... }: {
  networking = {
    usePredictableInterfaceNames = false;
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    defaultGateway = "100.100.0.0";
    interfaces = {
      eth0 = {
        useDHCP = true;
      };
    };
  };
}
