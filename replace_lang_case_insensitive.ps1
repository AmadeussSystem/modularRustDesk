$utf8NoBom = New-Object System.Text.UTF8Encoding $False

# Replace RustDesk with App case-insensitively in src/lang/*.rs
$files = Get-ChildItem -Path src\lang -Filter *.rs -File
foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, $utf8NoBom)
    $newContent = [System.Text.RegularExpressions.Regex]::Replace($content, 'rustdesk', 'app', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($content -cne $newContent) {
        [System.IO.File]::WriteAllText($file.FullName, $newContent, $utf8NoBom)
        Write-Host "Updated $($file.Name)"
    }
}

# Replace RustDesk with App case-insensitively in flutter/lib/**/*.dart
$flutter_files = Get-ChildItem -Path flutter\lib -Filter *.dart -Recurse -File
foreach ($file in $flutter_files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, $utf8NoBom)
    $newContent = [System.Text.RegularExpressions.Regex]::Replace($content, 'rustdesk', 'app', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if ($content -cne $newContent) {
        [System.IO.File]::WriteAllText($file.FullName, $newContent, $utf8NoBom)
        Write-Host "Updated $($file.Name)"
    }
}
