$utf8NoBom = New-Object System.Text.UTF8Encoding $False

# Replace RustDesk with App in src/lang/*.rs
$files = Get-ChildItem -Path src\lang -Filter *.rs -File
foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, $utf8NoBom)
    $newContent = $content.Replace('RustDesk', 'App').Replace('rustdesk', 'app')
    if ($content -cne $newContent) {
        [System.IO.File]::WriteAllText($file.FullName, $newContent, $utf8NoBom)
        Write-Host "Updated $($file.Name)"
    }
}
