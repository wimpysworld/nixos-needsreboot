use std::env;
use std::error::Error;
use std::fs;
use std::path::Path;

mod compare_nixos_modules;

pub static OLD_SYSTEM_PATH: &str = "/run/booted-system";
pub static NEW_SYSTEM_PATH: &str = "/run/current-system";

fn main() -> Result<(), Box<dyn Error>> {
    let env_args: Vec<String> = env::args().collect();

    if env_args.contains(&String::from("--version")) {
        println!("{}: v{}", env!("CARGO_PKG_NAME"), env!("CARGO_PKG_VERSION"));
        std::process::exit(0);
    }

    let new_system_path = if env_args.len() == 2 { &env_args[1] } else { NEW_SYSTEM_PATH };

    if Path::new("/nix/var/nix/profiles/system").exists() {
        let old_system_id = fs::read_to_string(OLD_SYSTEM_PATH.to_string() + "/nixos-version")?;
        let new_system_id = fs::read_to_string(new_system_path.to_string() + "/nixos-version")?;

        if old_system_id == new_system_id {
            eprintln!("DEBUG: you are using the latest NixOS generation, no need to reboot");
            std::process::exit(2);
        } else {
            let reason = compare_nixos_modules::upgrades_available()?;
            if reason.is_empty() {
                eprintln!("DEBUG: no updates available, moar uptime!!!");
                std::process::exit(2);
            } else {
                println!("{reason}");
            }
        }
    } else {
        eprintln!("This binary is intended to run only on NixOS.");
        std::process::exit(1);
    }

    Ok(())
}
