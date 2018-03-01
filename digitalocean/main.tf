
resource "digitalocean_tag" "k8s-master" {
  name = "k8s-master"
}

resource "digitalocean_tag" "k8s-node" {
  name = "k8s-node"
}

resource "digitalocean_droplet" "master" {
  image = "ubuntu-16-04-x64"
  name = "master"
  region = "nyc3"
  size = "2GB"
  private_networking = true
  tags = ["${digitalocean_tag.k8s-master.id}"]
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]

  connection {
    user = "root"
    type = "ssh"
    agent = true
    private_key = "${file(var.pvt_key)}"
    timeout = "2m"
  }

  provisioner "file" {
    source      = "master_setup.sh"
    destination = "/tmp/master_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/master_setup.sh",
      "/tmp/master_setup.sh ${var.discovery_token}",
    ]
  }

}

resource "digitalocean_droplet" "node" {
  image = "ubuntu-16-04-x64"
  count = 3
  name = "node-${count.index}"
  region = "nyc3"
  size = "2GB"
  private_networking = true
  tags = ["${digitalocean_tag.k8s-node.id}"]
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]

  connection {
    user = "root"
    type = "ssh"
    agent = true
    private_key = "${file(var.pvt_key)}"
    timeout = "2m"
  }

  provisioner "file" {
    source      = "node_setup.sh"
    destination = "/tmp/node_setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/node_setup.sh",
      "/tmp/node_setup.sh ${var.discovery_token} ${digitalocean_droplet.master.ipv4_address}",
    ]
  }
}

resource "digitalocean_loadbalancer" "public" {
  name = "loadbalancer-1"
  region = "nyc3"

  forwarding_rule {
    entry_port = 30443
    entry_protocol = "https"

    target_port = 30443
    target_protocol = "https"

    tls_passthrough = true
  }

  healthcheck {
    port = 22
    protocol = "tcp"
  }

  droplet_ids = ["${digitalocean_droplet.node.*.id}"]
}

resource "null_resource" "finalsetup" {
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i ~/.ssh/terraform root@${digitalocean_droplet.master.ipv4_address}:~/.kube/config ./kube-config"
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ./templates/dashboard.yaml --kubeconfig ./kube-config"
  }

  depends_on = ["digitalocean_loadbalancer.public"]
}

