terraform {
	required_providers {
		docker = {
			source  = "kreuzwerker/docker"
		}
	}
}

resource "docker_network" "appnet" {
	name = "appnet"
	driver = "bridge"
}

resource "docker_image" "prometheus" {
	name = "prom/prometheus"
}

resource "docker_image" "grafana" {
	name = "grafana/grafana"
}

resource "docker_image" "img-rabbitmq" {
	name = "rabbitmq:3.11-management"
}

resource "docker_image" "discoverer" {
	name = "shekeriev/rabbit-discoverer"
}

resource "docker_image" "observer" {
	name = "shekeriev/rabbit-observer"
}

resource "docker_container" "prometheus" {
	name = "prometheus"
	hostname = "prometheus"
	image = docker_image.prometheus.name
	networks_advanced {
		name = docker_network.appnet.id
	}
	ports {
		internal = 9090
		external = 9090
	}
	volumes {
		host_path = "/vagrant/terraform-containers/configs/prometheus.yml"
		container_path = "/etc/prometheus/prometheus.yml"
	}
}

resource "docker_container" "grafana" {
	name = "grafana"
	hostname = "grafana"
	image = docker_image.grafana.name
	networks_advanced {
		name = docker_network.appnet.id
	}
	ports {
		internal = 3000
		external = 3000
	}
	volumes {
		host_path = "/vagrant/terraform-containers/configs/datasource.yml"
		container_path = "/etc/grafana/provisioning/datasources/datasource.yaml"
	}
}

resource "docker_container" "rabbitmq" {
	name = "rabbitmq"
	hostname = "rabbitmq"
	image = docker_image.img-rabbitmq.image_id
	ports {
		internal = 5672
		external = 5672
	}
	ports {
		internal = 15672
		external = 15672
	}
	ports {
		internal = 15692
		external = 15692
	}
	networks_advanced {
		name = docker_network.appnet.name
	}
	volumes {
		host_path = "/vagrant/terraform-containers/configs/enabled_plugins"
		container_path = "/etc/rabbitmq/enabled_plugins"
	}
}

resource "docker_container" "discoverer" {
	name = "discoverer"
	hostname = "discoverer"
	image = docker_image.discoverer.name
	env = ["BROKER=rabbitmq", "EXCHANGE=animal-facts", "METRICPORT=15693"]
	networks_advanced {
		name = docker_network.appnet.id
	}
	ports {
		internal = 8888
		external = 5000
	}
}

resource "docker_container" "observer" {
	name = "observer"
	hostname = "observer"
	image = docker_image.observer.name
	env = ["BROKER=rabbitmq", "EXCHANGE=animal-facts"]
	networks_advanced {
		name = docker_network.appnet.id
	}
}
