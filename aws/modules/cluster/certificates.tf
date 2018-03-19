resource "null_resource" "certificates" {
  # triggers {
  #   template_rendered = "${ data.template_file.certificates.rendered }"
  # }
  # provisioner "local-exec" {
  #   command = "echo '${ data.template_file.certificates.rendered }' > ../cert/kubernetes-csr.json"
  # }

  provisioner "local-exec" {
    command = "cd ${path.module}/certs; rm -f *.pem; rm -f *.csr"
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/certs; cfssl gencert -initca ca-csr.json | cfssljson -bare ca"
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/certs; cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes admin-csr.json | cfssljson -bare admin"
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/certs; cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=kubernetes kube-proxy-csr.json | cfssljson -bare kube-proxy"
  }

  provisioner "local-exec" {
    command = "cd ${path.module}/certs; "
  }

  # cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,kubernetes.default -profile=kubernetes kubernetes-csr.json | cfssljson -bare kubernetes
}


# 10.32.0.1
# 10.240.0.10
# 10.240.0.11
# 10.240.0.12


