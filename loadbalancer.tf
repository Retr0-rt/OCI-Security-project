resource "oci_load_balancer_load_balancer" "public_lb" {
    compartment_id = var.compartemt_id
    display_name = "LB_Public_St26"
    subnet_ids = [oci_core_subnet.public_subnet.id]
    
    shape = "flexible"
    shape_details {
      minimum_bandwidth_in_mbps = 10
      maximum_bandwidth_in_mbps = 10
    }

    network_security_group_ids = [oci_core_network_security_group.lb_nsg.id]
}

resource "oci_load_balancer_backend_set" "app_backend_set" {
    name = "LB_backendset_App_St26"
    load_balancer_id = oci_load_balancer_load_balancer.public_lb.id
    policy = "ROUND_ROBIN"

    health_checker {
      protocol = "HTTP"
      port = var.web_port
      url_path = "/"
      return_code = 200
      retries = 3
      timeout_in_millis = 300
      interval_ms = 20000
    }
}

resource "oci_load_balancer_backend" "app_backend" {
    load_balancer_id = oci_load_balancer_load_balancer.public_lb.id
    backendset_name = oci_load_balancer_backend_set.app_backend_set.name
    ip_address = oci_core_instace.app_server.private_ip
    port = var.web_port
}

resource "oci_load_balancer_listener" "lb_http_listner" {
    load_balancer_id = oci_load_balancer_load_balancer.public_lb.id
    name = "LB_listener_HTTPS_St26"
    default_backend_set_name = oci_load_balancer_backend_set.app_backend_set.id
    port = var.web_port
    protocol = "HTTP"
}