{ lib, config, pkgs, ... }:

let
  cfg = config.services.esdm;
  kernelVersion = config.boot.kernelPackages.kernel.version;
  linux_6_3 = (builtins.compareVersions kernelVersion "6.3" >= 0);
in
{
  options.services.esdm = {
    enable = lib.mkEnableOption (lib.mdDoc "ESDM service configuration");
    package = lib.mkPackageOptionMD pkgs "esdm" { };
    kernel-enable = lib.mkEnableOption (lib.mdDoc "enable ESDM kernel module");
    server-enable = lib.mkEnableOption (lib.mdDoc "enable option for ESDM server service") // { default = true; };
    cuse-random-enable = lib.mkEnableOption (lib.mdDoc "enable option for ESDM cuse-random service")  // { default = true; };
    cuse-urandom-enable = lib.mkEnableOption (lib.mdDoc "enable option for ESDM cuse-urandom service") // { default = true; };
    proc-enable = lib.mkEnableOption (lib.mdDoc "enable option for ESDM proc service") // { default = true; };
    verbose-enable = lib.mkEnableOption (lib.mdDoc "enable verbose ExecStart for ESDM") // { default = true; };
  };

  config = lib.mkMerge [


    (lib.mkIf cfg.enable {
      #need the following lines for NixOS to recongnise, that it indeed should start these services
      systemd.packages = [ pkgs.esdm ];

      assertions = lib.lists.singleton {
        assertion = (linux_6_3 || cfg.kernel-enable) == true;
        message = "Expected kernel-version >= 6.3. got kernel-version:${kernelVersion}";
      };

      #patch kernel (works for kernel version 6.3)
      boot.kernelPatches = [ ]
        ++ lib.lists.optionals (linux_6_3 || cfg.kernel-enable) [
        {
          name = "esdm_sched_es_hook";
          patch = "${cfg.package}/addon/linux_esdm_es/0001-ESDM-scheduler-entropy-source-hooks_6.4.patch";
        }
        {
          name = "esdm_inter_es_hook";
          patch = "${cfg.package}/addon/linux_esdm_es/0002-ESDM-interrupt-entropy-source-hooks_6.4.patch";
        }
      ];
    })
    (lib.mkIf cfg.kernel-enable {
      boot.extraModulePackages = [ config.boot.kernelPackages.esdm_es.out ];
      boot.extraModprobeConfig = ''
          options esdm_es esdm_hash_name=sha3-512
      '';
      boot.kernelModules = [ "esdm_es" ];
    })

    (lib.mkIf cfg.server-enable {
      systemd.services."esdm-server".wantedBy = [ "basic.target" ];
    })

    (lib.mkIf cfg.cuse-random-enable {
      systemd.services."esdm-cuse-random".wantedBy = [ "basic.target" ];
    })

    (lib.mkIf cfg.cuse-urandom-enable {
      systemd.services."esdm-cuse-urandom".wantedBy = [ "basic.target" ];
    })

    (lib.mkIf cfg.proc-enable {
      systemd.services."esdm-proc".wantedBy = [ "basic.target" ];
      # systemd.services."esdm-proc".serviceConfig.ExecStart = lib.mkForce [''
      #   ${cfg.package}/esdm-proc --relabel -f -o allow_other /proc/sys/kernel/random -v 6
      # ''];
    }) 
    # // lib.attrsets.optionalAttrs cfg.verbose-enable {
    #   lib.mkForce systemd.services."esdm-proc".serviceConfig.ExecStart = [''
    #     pwd
    #     ls ./
    #     ${cfg.package}/esdm-proc --relabel -f -o allow_other /proc/sys/kernel/random -v 6
    #   ''
    #   ];
    # })
  ];

  meta.maintainers = with lib.maintainers; [ orichter thillux ];
}
