provider "google" {

credentials = file("/Users/AS/Desktop/Terraform LW/gpsvc.json")

project = "googleproject"
 region  = "us-central1"
 zone    = "us-central1-c"
}



resource "google_compute_instance" "apache_server" {
    name = "apache_server"
    machine_type = "f1-micro"

    tags = ["http-server"]

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-9"
        }
    }

    metadata_startup_script =  file("/Users/AS/Desktop/Terraform LW/apache2.sh")

scheduling {
        preemptible = true
        automatic_restart = false
    }

    network_interface {
        network ="default"
        access_config {

        }


}
}