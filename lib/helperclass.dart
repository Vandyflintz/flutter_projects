class SMethod {
  const SMethod(this.smval, this.smtext);
  final String smval;
  final String smtext;
}

class SFields {
  const SFields(this.sfval, this.sftext);
  final String sfval;
  final String sftext;
}

class WAdmins {
  const WAdmins(this.username, this.userid, this.usermail, this.usercontact,
      this.userimg);
  final String username;
  final String userid;
  final String usermail;
  final String usercontact;
  final String userimg;

  factory WAdmins.fromJson(dynamic json) {
    return WAdmins(
      json["name"],
      json["id"],
      json["email"],
      json["contact"],
      json["dp"],
    );
  }

  Map<String, dynamic> toMap() => {
        "name": username,
        "id": userid,
        "email": usermail,
        "contact": usercontact,
        "dp": userimg,
      };
}

class CWorkers {
  const CWorkers(this.username, this.userid, this.usermail, this.usercontact,
      this.userimg, this.channel);
  final String username;
  final String userid;
  final String usermail;
  final String usercontact;
  final String userimg;
  final String channel;

  factory CWorkers.fromJson(dynamic json) {
    return CWorkers(
      json["name"],
      json["id"],
      json["email"],
      json["contact"],
      json["dp"],
      json["channel"],
    );
  }

  Map<String, dynamic> toMap() => {
        "name": username,
        "id": userid,
        "email": usermail,
        "contact": usercontact,
        "dp": userimg,
        "channel": channel,
      };
}

class AllShippers {
  const AllShippers(this.shippername, this.shippercontact,
      this.shipperresidentialaddress, this.shipperemailaddress, this.totalcars);
  final String shippername;
  final String shippercontact;
  final String shipperresidentialaddress;
  final String shipperemailaddress;
  final String totalcars;

  factory AllShippers.fromJson(dynamic json) {
    return AllShippers(json["shipper"], json["contact"],
        json["residentialaddress"], json["emailaddress"], json["totalcars"]);
  }

  Map<String, dynamic> toMap() => {
        "shipper": shippername,
        "contact": shippercontact,
        "residentialaddress": shipperresidentialaddress,
        "emailaddress": shipperemailaddress,
        "totalcars": totalcars
      };
}

class InvoicesAndReceipts {
  const InvoicesAndReceipts(this.clientname, this.invoicenum, this.receiptnum);
  final String clientname;
  final String invoicenum;
  final String receiptnum;

  factory InvoicesAndReceipts.fromJson(dynamic json) {
    return InvoicesAndReceipts(
        json["client_name"], json["invoicenum"], json["receiptnum"]);
  }
}

class AllMessageWorkers {
  const AllMessageWorkers(this.img, this.uid, this.msgcount, this.username,
      this.lastmessage, this.timeofmsg);
  final String img;
  final String uid;
  final String msgcount;
  final String username;
  final String lastmessage;
  final String timeofmsg;

  factory AllMessageWorkers.fromJson(dynamic json) {
    return AllMessageWorkers(json["img"], json["uid"], json["msgcount"],
        json["username"], json["lastmessage"], json["timeofmsg"]);
  }

  Map<String, dynamic> toMap() => {
        "timeofmsg": timeofmsg,
        "img": img,
        "uid": uid,
        "msgcount": msgcount,
        "username": username,
        "lastmessage": lastmessage
      };
}

class AllChatWorkers {
  const AllChatWorkers(this.img, this.uid, this.username, this.channel);
  final String img;
  final String uid;
  final String username;
  final String channel;

  factory AllChatWorkers.fromJson(dynamic json) {
    return AllChatWorkers(
        json["img"], json["uid"], json["username"], json["channel"]);
  }
}

class OpenSelectedChat {
  const OpenSelectedChat(this.message, this.mtime, this.sender,
      this.messagetype, this.submessage, this.fsize);
  final String message;
  final String mtime;
  final String sender;
  final String messagetype;
  final String submessage;
  final String fsize;
  factory OpenSelectedChat.fromJson(dynamic json) {
    return OpenSelectedChat(json["message"], json["mtime"], json["sender"],
        json["messagetype"], json["submessage"], json["fsize"]);
  }
}

class CDebtors {
  const CDebtors(
      this.invoicenum,
      this.dateissued,
      this.totalamount,
      this.amtpaid,
      this.balance,
      this.name,
      this.contact,
      this.address,
      this.duration);
  final String invoicenum;
  final String dateissued;
  final String totalamount;
  final String amtpaid;
  final String balance;
  final String name;
  final String contact;
  final String address;
  final String duration;
  factory CDebtors.fromJson(dynamic json) {
    return CDebtors(
        json["invoicenum"],
        json["dateissued"],
        json["totalamount"].toString(),
        json["amtpaid"].toString(),
        json["balance"].toString(),
        json["name"],
        json["contact"].toString(),
        json["address"],
        json["duration"]);
  }
}

class ClientUpdatePayment {
  const ClientUpdatePayment(
      this.invoiceamount,
      this.rnum,
      this.amtpaid,
      this.lastpaid,
      this.clientname,
      this.clientcontact,
      this.clientaddress,
      this.clientchannel);
  final String invoiceamount;
  final String rnum;
  final String amtpaid;
  final String lastpaid;
  final String clientname;
  final String clientcontact;
  final String clientaddress;
  final String clientchannel;
  factory ClientUpdatePayment.fromJson(dynamic json) {
    return ClientUpdatePayment(
        json["invoiceamount"],
        json["rnum"],
        json["amtpaid"],
        json["lastpaid"],
        json["clientname"],
        json["clientcontact"],
        json["clientaddress"],
        json["channel"]);
  }

  Map<String, dynamic> toMap() => {
        "invoiceamount": invoiceamount,
        "rnum": rnum,
        "amtpaid": amtpaid,
        "lastpaid": lastpaid,
        "clientname": clientname,
        "clientcontact": clientcontact,
        "clientaddress": clientaddress,
        "channel": clientchannel
      };
}

class CarsUnshipped {
  const CarsUnshipped(
      this.channelname,
      this.channelid,
      this.carname,
      this.mainimg,
      this.make,
      this.model,
      this.year,
      this.color,
      this.carimages,
      this.mileage,
      this.engine,
      this.transmission,
      this.abs,
      this.lotnumber,
      this.wbl,
      this.trim,
      this.madein,
      this.chassisno,
      this.dimensions,
      this.drivetrain,
      this.towingcost,
      this.shippingcost,
      this.purchasingcost,
      this.carpartscost,
      this.body,
      this.shippername,
      this.shippercontact,
      this.shipperemailaddress,
      this.shipperresidentialaddress,
      this.caraddress);
  final String channelname;
  final String channelid;
  final String carname;
  final String mainimg;
  final String make;
  final String model;
  final String year;
  final String color;
  final String carimages;
  final String mileage;
  final String engine;
  final String transmission;
  final String abs;
  final String lotnumber;
  final String wbl;
  final String trim;
  final String madein;
  final String chassisno;
  final String dimensions;
  final String drivetrain;
  final String towingcost;
  final String shippingcost;
  final String carpartscost;
  final String purchasingcost;
  final String body;
  final String shippername;
  final String shippercontact;
  final String shipperemailaddress;
  final String shipperresidentialaddress;
  final String caraddress;

  factory CarsUnshipped.fromJson(dynamic json) {
    return CarsUnshipped(
        json["channelname"],
        json["channelid"],
        json["carname"],
        json["mainimage"],
        json["make"],
        json["model"],
        json["year"],
        json["color"],
        json["carimages"],
        json["mileage"],
        json["engine"],
        json["transmission"],
        json["abs"],
        json["lotnumber"],
        json["wbl"],
        json["trim"],
        json["madein"],
        json["chassisno"],
        json["dimensions"],
        json["drivetrain"],
        json["towingcost"],
        json["shippingcost"],
        json["purchasingcost"],
        json["carpartscost"],
        json["body"],
        json["shippername"],
        json["shippercontact"],
        json["shipperemailaddress"],
        json["shipperresidentialaddress"],
        json["caraddress"]);
  }
}

class CarsShipped {
  const CarsShipped(
      this.channelname,
      this.channelid,
      this.carname,
      this.mainimg,
      this.make,
      this.model,
      this.year,
      this.color,
      this.carimages,
      this.mileage,
      this.engine,
      this.transmission,
      this.abs,
      this.lotnumber,
      this.wbl,
      this.trim,
      this.madein,
      this.chassisno,
      this.dimensions,
      this.drivetrain,
      this.towingcost,
      this.shippingcost,
      this.purchasingcost,
      this.carpartscost,
      this.body);
  final String channelname;
  final String channelid;
  final String carname;
  final String mainimg;
  final String make;
  final String model;
  final String year;
  final String color;
  final String carimages;
  final String mileage;
  final String engine;
  final String transmission;
  final String abs;
  final String lotnumber;
  final String wbl;
  final String trim;
  final String madein;
  final String chassisno;
  final String dimensions;
  final String drivetrain;
  final String towingcost;
  final String shippingcost;
  final String carpartscost;
  final String purchasingcost;
  final String body;

  factory CarsShipped.fromJson(dynamic json) {
    return CarsShipped(
        json["channelname"],
        json["channelid"],
        json["carname"],
        json["mainimage"],
        json["make"],
        json["model"],
        json["year"],
        json["color"],
        json["carimages"],
        json["mileage"],
        json["engine"],
        json["transmission"],
        json["abs"],
        json["lotnumber"],
        json["wbl"],
        json["trim"],
        json["madein"],
        json["chassisno"],
        json["dimensions"],
        json["drivetrain"],
        json["towingcost"],
        json["shippingcost"],
        json["purchasingcost"],
        json["carpartscost"],
        json["body"]);
  }
}

class SoldCars {
  const SoldCars(
      this.channelname,
      this.channelid,
      this.carname,
      this.mainimg,
      this.make,
      this.model,
      this.year,
      this.color,
      this.carimages,
      this.mileage,
      this.engine,
      this.transmission,
      this.abs,
      this.lotnumber,
      this.wbl,
      this.trim,
      this.madein,
      this.chassisno,
      this.dimensions,
      this.drivetrain,
      this.towingcost,
      this.shippingcost,
      this.purchasingcost,
      this.carpartscost,
      this.body,
      this.shippername,
      this.shippercontact,
      this.shipperemailaddress,
      this.shipperresidentialaddress,
      this.caraddress,
      this.worker,
      this.buyername,
      this.buyerphone,
      this.buyeraddress);
  final String channelname;
  final String channelid;
  final String carname;
  final String mainimg;
  final String make;
  final String model;
  final String year;
  final String color;
  final String carimages;
  final String mileage;
  final String engine;
  final String transmission;
  final String abs;
  final String lotnumber;
  final String wbl;
  final String trim;
  final String madein;
  final String chassisno;
  final String dimensions;
  final String drivetrain;
  final String towingcost;
  final String shippingcost;
  final String carpartscost;
  final String purchasingcost;
  final String body;
  final String shippername;
  final String shippercontact;
  final String shipperemailaddress;
  final String shipperresidentialaddress;
  final String caraddress;
  final String worker;
  final String buyername;
  final String buyerphone;
  final String buyeraddress;

  factory SoldCars.fromJson(dynamic json) {
    return SoldCars(
      json["channelname"],
      json["channelid"],
      json["carname"],
      json["mainimage"],
      json["make"],
      json["model"],
      json["year"],
      json["color"],
      json["carimages"],
      json["mileage"],
      json["engine"],
      json["transmission"],
      json["abs"],
      json["lotnumber"],
      json["wbl"],
      json["trim"],
      json["madein"],
      json["chassisno"],
      json["dimensions"],
      json["drivetrain"],
      json["towingcost"],
      json["shippingcost"],
      json["purchasingcost"],
      json["carpartscost"],
      json["body"],
      json["shippername"],
      json["shippercontact"],
      json["shipperemailaddress"],
      json["shipperresidentialaddress"],
      json["caraddress"],
      json["worker"],
      json["buyername"],
      json["buyerphone"],
      json["buyeraddress"],
    );
  }
}

class TransferredCars {
  const TransferredCars(
      this.channelname,
      this.channelid,
      this.carname,
      this.mainimg,
      this.make,
      this.model,
      this.year,
      this.color,
      this.carimages,
      this.mileage,
      this.engine,
      this.transmission,
      this.abs,
      this.lotnumber,
      this.wbl,
      this.trim,
      this.madein,
      this.chassisno,
      this.dimensions,
      this.drivetrain,
      this.towingcost,
      this.shippingcost,
      this.purchasingcost,
      this.carpartscost,
      this.body,
      this.transferredby,
      this.fromchan,
      this.tochan);
  final String channelname;
  final String channelid;
  final String carname;
  final String mainimg;
  final String make;
  final String model;
  final String year;
  final String color;
  final String carimages;
  final String mileage;
  final String engine;
  final String transmission;
  final String abs;
  final String lotnumber;
  final String wbl;
  final String trim;
  final String madein;
  final String chassisno;
  final String dimensions;
  final String drivetrain;
  final String towingcost;
  final String shippingcost;
  final String carpartscost;
  final String purchasingcost;
  final String body;
  final String transferredby;
  final String fromchan;
  final String tochan;

  factory TransferredCars.fromJson(dynamic json) {
    return TransferredCars(
      json["channelname"],
      json["channelid"],
      json["carname"],
      json["mainimage"],
      json["make"],
      json["model"],
      json["year"],
      json["color"],
      json["carimages"],
      json["mileage"],
      json["engine"],
      json["transmission"],
      json["abs"],
      json["lotnumber"],
      json["wbl"],
      json["trim"],
      json["madein"],
      json["chassisno"],
      json["dimensions"],
      json["drivetrain"],
      json["towingcost"],
      json["shippingcost"],
      json["purchasingcost"],
      json["carpartscost"],
      json["body"],
      json["transferredby"],
      json["fromchan"],
      json["tochan"],
    );
  }
}

class WRoles {
  const WRoles(this.channel, this.roleid, this.role);
  final String channel;
  final String roleid;
  final String role;

  factory WRoles.fromJson(dynamic json) {
    return WRoles(json["channelid"], json["roleid"], json["role"]);
  }

  Map<String, dynamic> toMap() =>
      {"channelid": channel, "roleid": roleid, "role": role};
}

class WRanks {
  const WRanks(this.channel, this.rankid, this.rank);
  final String channel;
  final String rankid;
  final String rank;

  factory WRanks.fromJson(dynamic json) {
    return WRanks(json["channelid"], json["rankid"], json["rank"]);
  }

  Map<String, dynamic> toMap() =>
      {"channelid": channel, "rankid": rankid, "rank": rank};
}

class CChanels {
  const CChanels(this.channelID, this.channelName);
  final String channelID;
  final String channelName;

  factory CChanels.fromJson(dynamic json) {
    return CChanels(json["channel_id"], json["channel_name"]);
  }

  Map<String, dynamic> toMap() =>
      {"channel_id": channelID, "channel_name": channelName};
}

class ColorData {
  const ColorData(this.colorid, this.colorname);
  final String colorid;
  final String colorname;

  factory ColorData.fromJson(dynamic json) {
    return ColorData(json["hex"], json["name"]);
  }

  Map<String, dynamic> toMap() => {"hex": colorid, "name": colorname};
}

class PaymentMethod {
  const PaymentMethod(this.paymentval, this.paymentname);
  final String paymentval;
  final String paymentname;

  factory PaymentMethod.fromJson(dynamic json) {
    return PaymentMethod(json["paymentval"], json["paymentname"]);
  }

  Map<String, dynamic> toMap() =>
      {"paymentval": paymentval, "paymentname": paymentname};
}

class GeneralCarData {
  const GeneralCarData(this.channelid, this.channelname, this.totalnum);
  final String channelid;
  final String channelname;
  final String totalnum;

  factory GeneralCarData.fromJson(dynamic json) {
    return GeneralCarData(
        json["channelid"], json["channelname"], json["totalcars"]);
  }

  Map<String, dynamic> toMap() => {
        "channelid": channelid,
        "channelname": channelname,
        "totalcars": totalnum
      };
}

class CarApiData {
  const CarApiData(
      this.make,
      this.model,
      this.year,
      this.trim,
      this.drivetrain,
      this.body,
      this.engine,
      this.mileage,
      this.chassisno,
      this.country,
      this.transmission,
      this.dimension,
      this.wbl,
      this.abs);
  final String make;
  final String model;
  final String year;
  final String trim;
  final String drivetrain;
  final String body;
  final String engine;
  final String mileage;
  final String chassisno;
  final String country;
  final String transmission;
  final String dimension;
  final String wbl;
  final String abs;

  factory CarApiData.fromJson(dynamic json) {
    return CarApiData(
        json["make"],
        json["model"],
        json["year"],
        json["trim"],
        json["drivetrain"],
        json["style"],
        json["engine"],
        "city mileage : " +
            json["city_mileage"] +
            ", highway mileage : " +
            json["highway_mileage"],
        json["vin"],
        json["made_in"],
        json["transmission"],
        "height : " +
            json["overall_height"] +
            ",  length : " +
            json["overall_length"] +
            ", width : " +
            json["overall_width"],
        json["wheelbase_length"],
        json["anti_brake_system"]);
  }

  Map<String, dynamic> toMap() => {
        "make": make,
        "model": model,
        "year": year,
        "trim": trim,
        "drivetrain": drivetrain,
        "body": body,
        "engine": engine,
        "mileage": mileage,
        "chassisno": chassisno,
        "country": country,
        "transmission": transmission,
        "dimension": dimension,
        "wbl": wbl,
        "abs": abs
      };
}
