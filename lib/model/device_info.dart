
class DeviceInfo {

  String? device;
  String? email;
  String? version;
  String? regid;
  int? dateCreate;

  DeviceInfo();

  DeviceInfo.fromJson(Map<String, dynamic> json) {
    this.device = json['device'];
    this.email = json['email'];
    this.version = json['version'];
    this.dateCreate = json['date_create'];
    this.regid = json['regid'];
  }

  Map<String, dynamic> toJson() => {
    'device': device,
    'email': email,
    'version': version,
    'date_create': dateCreate,
    'regid': regid,
  };

}