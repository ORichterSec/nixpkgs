{ lib, config, pkgs, ... }:

let
  cfg = config.services.esdm;
  kernelVersion = config.boot.kernelPackages.kernel.version;
  isAtLeastLinux63 = (lib.versionAtLeast kernelVersion "6.3");
in
{
  options.services.esdm = {
    enable = lib.mkEnableOption (lib.mdDoc "ESDM service configuration");
    package = lib.mkPackageOptionMD pkgs "esdm" { };
    kernelSupportEnable = lib.mkEnableOption (lib.mdDoc "Enable kernel support for the scheduler- and interrupt-entropy-source.");
    serverEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc ''
        Enable option for ESDM server service. If serverEnable == false, then the esdm-server
        will not start. Also the subsequent services esdm-cuse-random, esdm-cuse-urandom
        and esdm-proc will not start as these have the entry Want=esdm-server.service.
      '';
    };
    cuseRandomEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc ''
        Enable option for ESDM cuse-random service. Determines if the esdm-cuse-random.service
        is started.
      '';
    };
    cuseUrandomEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc ''
        Enable option for ESDM cuse-urandom service. Determines if the esdm-cuse-urandom.service
        is started.
      '';
    };
    procEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc ''
        Enable option for ESDM proc service. Determines if the esdm-proc.service
        is started.
      '';
    };
    verbose = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc ''
        Enable verbose ExecStart for ESDM. If verbose == true, then the corresponding "ExecStart"
        values of the 4 aforementioned services are overwritten with the option
        for the highest verbosity.
      '';
    };
    esdmHashName = lib.mkOption {
      type = lib.types.str;
      default = "sha3-512";
      description = lib.mdDoc ''
        Set the hash configration of the kernel module esdm_es.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      ({
        systemd.packages = [ cfg.package ];
      })
      (lib.mkIf cfg.kernelSupportEnable {
        assertions = lib.lists.singleton {
          assertion = isAtLeastLinux63;
          message = "ESDM expects kernel version >= 6.3. current kernel version: ${kernelVersion}";
        };

        boot.extraModulePackages = [ config.boot.kernelPackages.esdm_es.out ];
        boot.extraModprobeConfig = ''
          options esdm_es esdm_hash_name=${cfg.esdmHashName}
        '';
        boot.kernelModules = [ "esdm_es" ];

        #patch kernel (works for kernel version 6.3)
        boot.kernelPatches = lib.lists.optionals isAtLeastLinux63 [
          {
            name = "esdm_sched_es_hook";
            patch = "${cfg.package}/share/linux_esdm_es/0001-ESDM-scheduler-entropy-source-hooks_6.4.patch";
          }
          {
            name = "esdm_inter_es_hook";
            patch = "${cfg.package}/share/linux_esdm_es/0002-ESDM-interrupt-entropy-source-hooks_6.4.patch";
          }
        ];
      })

      # It is necessary to set those options for these services to be started by systemd in NixOS
      (lib.mkIf cfg.serverEnable {
        systemd.services."esdm-server".wantedBy = [ "basic.target" ];
        systemd.services."esdm-server".serviceConfig = lib.mkIf cfg.verbose {
          ExecStart = [
            " " # unset previous value defined in 'esdm-server.service'
            "${cfg.package}/bin/esdm-server -f -vvvvvv"
          ];
        };
      })

      (lib.mkIf cfg.cuseRandomEnable {
        systemd.services."esdm-cuse-random".wantedBy = [ "basic.target" ];
        systemd.services."esdm-cuse-random".serviceConfig = lib.mkIf cfg.verbose {
          ExecStart = [
            " " # unset previous value defined in 'esdm-cuse-random.service'
            "${cfg.package}/bin/esdm-cuse-random -f -v 6"
          ];
        };
      })

      (lib.mkIf cfg.cuseUrandomEnable {
        systemd.services."esdm-cuse-urandom".wantedBy = [ "basic.target" ];
        systemd.services."esdm-cuse-urandom".serviceConfig = lib.mkIf cfg.verbose {
          ExecStart = [
            " " # unset previous value defined in 'esdm-cuse-urandom.service'
            "${config.services.esdm.package}/bin/esdm-cuse-urandom -f -v 6"
          ];
        };
      })

      (lib.mkIf cfg.procEnable {
        systemd.services."esdm-proc".wantedBy = [ "basic.target" ];
        systemd.services."esdm-proc".serviceConfig = lib.mkIf cfg.verbose {
          ExecStart = [
            " " # unset previous value defined in 'esdm-proc.service'
            "${cfg.package}/bin/esdm-proc --relabel -f -o allow_other /proc/sys/kernel/random -v 6"
          ];
        };
      })
    ]);

  meta.maintainers = with lib.maintainers; [ orichter thillux ];
}
