class RespDevice {

  String? status = "";
  String? message = "";

  RespDevice({this.status, this.message});

  RespDevice.fromJson(Map<String, dynamic> json) {
    this.status = json['status'];
    this.message = json['message'];
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
  };
}
