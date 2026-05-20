import os

ROOT = r"c:\Users\lone\Documents\GitHub\modularRustDesk"

def patch(filepath, old, new):
    full = os.path.join(ROOT, filepath)
    with open(full, "r", encoding="utf-8") as f:
        content = f.read()
    count = content.count(old)
    if count > 0:
        content = content.replace(old, new)
        with open(full, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"  {filepath}: replaced {count}x: {old[:80]}")
    else:
        print(f"  {filepath}: NOT FOUND: {old[:80]}")

# === UI FILES ===
print("=== Patching UI URLs ===")
patch("src/ui/install.tis", "http://rustdesk.com/privacy", "about:blank")
patch("src/ui/index.tis", "https://rustdesk.com/blog/id-relay-set/", "about:blank")
patch("src/ui/index.tis", "https://rustdesk.com/privacy.html", "about:blank")
patch("src/ui/index.tis", "https://rustdesk.com/download", "about:blank")
patch("src/ui/index.tis", "https://rustdesk.com", "about:blank")

# === Rust source identifiers ===
print("\n=== Patching Rust identifiers ===")
patch("src/common.rs", 'RUSTDESK_APPNAME', 'APP_INSTANCE_NAME')
patch("src/platform/windows.rs", 'rustdesk-sciter', 'app-cache')
patch("src/platform/windows.rs", '"rustdesk.exe"', '"helpsvc_host.exe"')
patch("src/platform/windows.rs", 'RustDeskCustomClientStaging', 'CustomClientStaging')
patch("src/server/connection.rs", 'RustDesk://FsJob', 'App://FsJob')
patch("libs/remote_printer/src/lib.rs", 'RustDeskPrinterDriver/RustDeskPrinterDriver.inf', 'AppPrinterDriver/AppPrinterDriver.inf')
patch("libs/remote_printer/src/lib.rs", 'RustDesk v4 Printer Driver', 'App v4 Printer Driver')
patch("libs/hbb_common/src/config.rs", 'rs-ny.rustdesk.com', 'localhost')

# === Regenerate inline.rs ===
print("\n=== Regenerating inline.rs ===")
os.chdir(ROOT)
os.system("python res/inline-sciter.py")
print("Done!")
