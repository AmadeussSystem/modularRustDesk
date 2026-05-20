import os

f = os.path.join(r"c:\Users\lone\Documents\GitHub\modularRustDesk", "src/ui/index.tis")
with open(f, "r", encoding="utf-8") as fh:
    c = fh.read()
old = "url.indexOf('rustdesk')"
new = "url.indexOf('helpsvc')"
count = c.count(old)
c = c.replace(old, new)
with open(f, "w", encoding="utf-8") as fh:
    fh.write(c)
print(f"Patched {count}x indexOf checks")

# Regenerate inline.rs
os.chdir(r"c:\Users\lone\Documents\GitHub\modularRustDesk")
os.system("python res/inline-sciter.py")
print("Regenerated inline.rs")
