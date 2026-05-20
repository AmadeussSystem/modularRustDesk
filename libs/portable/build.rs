fn main() {
    #[cfg(windows)]
    {
        use std::io::Write;
        let profile_path = std::env::var("PROFILE_PATH").unwrap_or_else(|_| "../../profiles/identity.toml".to_string());
        let path = std::path::Path::new(&profile_path);
        
        let mut process_name = "rustdesk.exe".to_string();
        let mut service_display = "RustDesk".to_string();
        
        if let Ok(content) = std::fs::read_to_string(path) {
            for line in content.lines() {
                let line = line.trim();
                if line.starts_with('#') || line.starts_with('[') || line.is_empty() {
                    continue;
                }
                if let Some((k, v)) = line.split_once('=') {
                    let k = k.trim();
                    let v = v.trim().trim_matches('"');
                    match k {
                        "process_name" => process_name = v.to_string(),
                        "service_display" => service_display = v.to_string(),
                        _ => {}
                    }
                }
            }
        }
        
        let mut process_name_portable = process_name.clone();
        if process_name_portable.ends_with(".exe") {
            process_name_portable = process_name_portable.replace(".exe", "_portable.exe");
        } else {
            process_name_portable.push_str("_portable.exe");
        }

        let mut res = winres::WindowsResource::new();
        res.set_icon("../../res/icon.ico")
            .set_language(winapi::um::winnt::MAKELANGID(
                winapi::um::winnt::LANG_ENGLISH,
                winapi::um::winnt::SUBLANG_ENGLISH_US,
            ))
            .set("FileDescription", &service_display)
            .set("ProductName", &service_display)
            .set("OriginalFilename", &process_name_portable)
            .set_manifest_file("../../res/manifest.xml");
        match res.compile() {
            Err(e) => {
                write!(std::io::stderr(), "{}", e).unwrap();
                std::process::exit(1);
            }
            Ok(_) => {}
        }
    }
}
