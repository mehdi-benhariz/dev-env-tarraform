provisioner "local-exec" {
  command = <<EOT
    powershell -Command "Add-Content -Path 'C:\Users\benha\.ssh\config' -Value @'
    Host ${hostname}
      HostName ${hostname}
      User ${user}
      IdentityFile ${identityfile}
    '@"
  EOT
}