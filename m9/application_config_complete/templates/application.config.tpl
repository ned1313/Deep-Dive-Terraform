# Change every time hosts are added or removed
host_list {
    %{ for host in hosts ~}
    hostname ${host}
    %{ endfor ~}
}

app_config {
    site_name = "${site_name}"
    api_key = "${api_key}"
}