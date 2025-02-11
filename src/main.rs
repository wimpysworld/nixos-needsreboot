use std::env;
use std::error::Error;
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
        let reason = compare_nixos_modules::upgrades_available(new_system_path)?;
        if reason.is_empty() {
            eprintln!("\x1b[32m󰔚\x1b[0m No reboot required, more uptime!");
            std::process::exit(2);
        } else {
            println!("\x1b[31m\x1b[0m Reboot required, uptime is ruined by {reason}");
        }
    } else {
        eprintln!("\x1b[34m󱄅\x1b[0m This binary is intended to run only on NixOS.");
        std::process::exit(1);
    }

    Ok(())
}
