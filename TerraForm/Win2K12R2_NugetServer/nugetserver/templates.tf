resource "template_file" "nuget_server_userdata" {
  template = "${file("templates/userdata/nugetserver/userdata.ps1")}"
  vars {
    apiKey = "${var.nuget_api_key}"
    packagesPath = "${var.packagesPath}"
  }
}
