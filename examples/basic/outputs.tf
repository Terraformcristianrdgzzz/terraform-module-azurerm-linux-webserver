output "website_url" {
  description = "HTTP URL for the Apache welcome page."
  value       = module.webserver.website_url
}

output "public_ip_address" {
  description = "Public IPv4 address assigned to the VM."
  value       = module.webserver.public_ip_address
}
