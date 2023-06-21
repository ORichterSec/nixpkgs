{ lib, config, pkgs, ... }:

let
  cfg = config.services.esdm;
  kernelVersion = config.boot.kernelPackages.kernel.version;
  linux_6_3 = (lib.versionAtLeast kernelVersion "6.3");
in
{
  options.services.esdm = {
    enable = lib.mkEnableOption (lib.mdDoc "ESDM service configuration");
    package = lib.mkPackageOptionMD pkgs "esdm" { };
    kernelEnable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc ''
        enable ESDM kernel module
      '';
    };
    serverEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc ''
        enable option for ESDM server service
      '';
    };
    cuseRandomEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc ''
        enable option for ESDM cuse-random service
      '';
    };
    cuseUrandomEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc ''
        enable option for ESDM cuse-urandom service
      '';
    };
    procEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc ''
        enable option for ESDM proc service
      '';
    };
    verbose = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = lib.mdDoc ''
        enable verbose ExecStart for ESDM
      '';
    };
    esdmHashName = lib.mkOption {
      type = lib.types.str;
      default = "sha3-512";
      description = lib.mdDoc ''
        hash configration of the kernel module esdm_es
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      ({
        systemd.packages = [ cfg.package ];

        assertions = lib.lists.singleton {
          assertion = (linux_6_3 || cfg.kernelEnable) == true;
          message = "Expected kernel-version >= 6.3. got kernel-version:${kernelVersion}";
        };
      })
      (lib.mkIf cfg.kernelEnable {
        boot.extraModulePackages = [ config.boot.kernelPackages.esdm_es.out ];
        boot.extraModprobeConfig = ''
          options esdm_es esdm_hash_name=${cfg.esdmHashName}
        '';
        boot.kernelModules = [ "esdm_es" ];

        #patch kernel (works for kernel version 6.3)
        boot.kernelPatches = [ ]
          ++ lib.lists.optionals linux_6_3 [
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

      #need the following lines for NixOS to recongnize, that it indeed should start these services
      (lib.mkIf cfg.serverEnable {
        systemd.services."esdm-server".wantedBy = [ "basic.target" ];
        systemd.services."esdm-server".serviceConfig = lib.mkIf cfg.verbose {
          ExecStart = [
            " " # unset previous value defined in 'esdm-server.service.in'
            "${cfg.package}/bin/esdm-server -f -vvvvvv"
          ];
        };
      })

      (lib.mkIf cfg.cuseRandomEnable {
        systemd.services."esdm-cuse-random".wantedBy = [ "basic.target" ];
        systemd.services."esdm-cuse-random".serviceConfig = lib.mkIf cfg.verbose {
          ExecStart = [
            " " # unset previous value defined in 'esdm-cuse-random.service.in'
            "${cfg.package}/bin/esdm-cuse-random -f -v 6"
          ];
        };
      })

      (lib.mkIf cfg.cuseUrandomEnable {
        systemd.services."esdm-cuse-urandom".wantedBy = [ "basic.target" ];
        systemd.services."esdm-cuse-urandom".serviceConfig = lib.mkIf cfg.verbose {
          ExecStart = [
            " " # unset previous value defined in 'esdm-cuse-urandom.service.in'
            "${config.services.esdm.package}/bin/esdm-cuse-urandom -f -v 6"
          ];
        };
      })

      (lib.mkIf cfg.procEnable {
        systemd.services."esdm-proc".wantedBy = [ "basic.target" ];
        systemd.services."esdm-proc".serviceConfig = lib.mkIf cfg.verbose {
          ExecStart = [
            " " # unset previous value defined in 'esdm-proc.service.in'
            "${cfg.package}/bin/esdm-proc --relabel -f -o allow_other /proc/sys/kernel/random -v 6"
          ];
        };
      })
    ]);

  meta.maintainers = with lib.maintainers; [ orichter thillux ];
}
