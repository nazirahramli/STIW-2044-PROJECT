import 'dart:async';
import 'dart:convert';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:goldenbread/user.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:random_string/random_string.dart';
import 'mainscreen.dart';
import 'payment.dart';
import 'package:intl/intl.dart';
import 'package:carousel_pro/carousel_pro.dart';

class CartScreen extends StatefulWidget {
  final User user;

  const CartScreen({Key key, this.user}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String server = "https://seriouslaa.com/goldenbread";
  List cartData;
  double screenHeight, screenWidth;
  bool _selfPickup = true;
  bool _storeCredit = false;
  bool _homeDelivery = false;
  double _totalprice = 0.0;
  Position _currentPosition;
  String curaddress;
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController gmcontroller;
  CameraPosition _home;
  MarkerId markerId1 = MarkerId("12");
  Set<Marker> markers = Set();
  double latitude, longitude;
  String label;
  CameraPosition _userpos;
  double deliverycharge;
  double amountpayable;

  @override
  void initState() {
    super.initState();
    _getLocation();
    //_getCurrentLocation();
    _loadCart();
  }

  @override
  Widget build(BuildContext context) {
    Widget image_carousel = new Container(
      height: 200,
      child: new Carousel(
        boxFit: BoxFit.cover,
        images: [
          AssetImage('assets/images/pay.jpg'),
          AssetImage('assets/images/ship.jpg'),
          AssetImage('assets/images/receive.jpg'),
        ],
        autoplay: true,
      ),
    );

    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    if (cartData == null) {
      return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text('My Cart'),
          ),
          body: Container(
              child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Loading Your Cart",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                )
              ],
            ),
          )));
    } else {
      return Scaffold(
        bottomSheet: Container(
            color: Colors.grey[300],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                    "Total Amount : RM" + amountpayable.toStringAsFixed(2) ??
                        "0.0",
                    style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
                SizedBox(
                  width: 10,
                ),
                MaterialButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  minWidth: 100,
                  height: 40,
                  child: Text("Make Payment"),
                  color: Colors.red[400],
                  textColor: Colors.white,
                  elevation: 10,
                  onPressed: makePaymentDialog,
                ),
              ],
            )),
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text('My Cart'),
          actions: <Widget>[
            IconButton(
              color: Colors.red[400],
              icon: Icon(MdiIcons.deleteEmpty),
              onPressed: () {
                deleteAll();
              },
            ),
          ],
        ),
        body: Container(
          child: ListView.builder(
              itemCount: cartData == null ? 1 : cartData.length + 2,
              itemBuilder: (context, index) {
                if (index == cartData.length) {
                  return Container(
                      height: screenHeight / 1.6,
                      width: screenWidth / 2.5,
                      child: InkWell(
                        onLongPress: () => {print("Delete")},
                        child: Card(
                          color: Colors.white,
                          elevation: 5,
                          child: Column(
                            children: <Widget>[
                              image_carousel,
                              SizedBox(
                                height: 10,
                              ),
                              Text("Delivery Option",
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                              Text("Subtotal: RM" + _totalprice.toString(),
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red[400])),
                              Expanded(
                                  child: Row(
                                children: <Widget>[
                                  Container(
                                    // color: Colors.red,
                                    width: screenWidth / 2,
                                    // height: screenHeight / 3,
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Checkbox(
                                              activeColor: Colors.red[400],
                                              value: _selfPickup,
                                              onChanged: (bool value) {
                                                _onSelfPickUp(value);
                                              },
                                            ),
                                            Text(
                                              "Self Pickup",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                      padding: EdgeInsets.fromLTRB(2, 1, 2, 1),
                                      child: SizedBox(
                                          width: 2,
                                          child: Container(
                                            // height: screenWidth / 2,
                                            color: Colors.grey,
                                          ))),
                                  Expanded(
                                      child: Container(
                                    //color: Colors.blue,
                                    width: screenWidth / 2,
                                    //height: screenHeight / 3,
                                    child: Column(
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Checkbox(
                                              activeColor: Colors.red[400],
                                              value: _homeDelivery,
                                              onChanged: (bool value) {
                                                _onHomeDelivery(value);
                                              },
                                            ),
                                            Text(
                                              "Home Delivery",
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        FlatButton(
                                          color: Colors.red[400],
                                          onPressed: () => {_loadMapDialog()},
                                          child: Icon(
                                            MdiIcons.locationEnter,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text("Current Address:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black)),
                                        Row(
                                          children: <Widget>[
                                            Text("  "),
                                            Flexible(
                                              child: Text(
                                                curaddress ?? "Address not set",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ))
                            ],
                          ),
                        ),
                      ));
                }
                if (index == cartData.length + 1) {
                  return Container(
                      //height: screenHeight / 3,
                      child: Card(
                    color: Colors.white,
                    elevation: 5,
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        Text("Payment Detail",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        SizedBox(height: 10),
                        Container(
                            padding: EdgeInsets.fromLTRB(50, 0, 50, 0),
                            //color: Colors.red,
                            child: Table(
                                defaultColumnWidth: FlexColumnWidth(1.0),
                                columnWidths: {
                                  0: FlexColumnWidth(7),
                                  1: FlexColumnWidth(3),
                                },
                                //border: TableBorder.all(color: Colors.white),
                                children: [
                                  TableRow(children: [
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 20,
                                          child: Text("Subtotal ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black))),
                                    ),
                                    TableCell(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        height: 20,
                                        child: Text(
                                            "RM" +
                                                    _totalprice
                                                        .toStringAsFixed(2) ??
                                                "0.0",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.black)),
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 20,
                                          child: Text("Shipping Fee (3%)",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black))),
                                    ),
                                    TableCell(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        height: 20,
                                        child: Text(
                                            "RM" +
                                                    deliverycharge
                                                        .toStringAsFixed(2) ??
                                                "0.0",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.black)),
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 20,
                                          child: Text(
                                              "Store Credit RM" +
                                                  widget.user.credit,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black))),
                                    ),
                                    TableCell(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        height: 20,
                                        child: Checkbox(
                                          activeColor: Colors.red[400],
                                          value: _storeCredit,
                                          onChanged: (bool value) {
                                            _onStoreCredit(value);
                                          },
                                        ),
                                      ),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 20,
                                          child: Text("Total Amount ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black))),
                                    ),
                                    TableCell(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        height: 20,
                                        child: Text(
                                            "RM" +
                                                    amountpayable
                                                        .toStringAsFixed(2) ??
                                                "0.0",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.red[400])),
                                      ),
                                    ),
                                  ]),
                                ])),
                        SizedBox(
                          height: 60,
                        ),
                      ],
                    ),
                  ));
                }
                index -= 0;

                return Card(
                  child: ListTile(
                      onTap: () => {_deleteCart(index)},
                      leading: new CachedNetworkImage(
                        fit: BoxFit.fill,
                        imageUrl:
                            "http://seriouslaa.com/goldenbread/productimage/${cartData[index]['id']}.jpg",
                        placeholder: (context, url) =>
                            new CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            new Icon(Icons.error),
                        width: 80.0,
                        height: 80.0,
                      ),
                      title: new Text(
                        cartData[index]['name'],
                      ),
                      subtitle: new Column(
                        children: <Widget>[
                          new Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: new Text("Price: "),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: new Text(
                                  "\$" + cartData[index]['price'],
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                          new Row(children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: new Text("Left: "),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: new Text(
                                cartData[index]['quantity'],
                                style: TextStyle(color: Colors.red),
                              ),
                            )
                          ]),
                          new Container(
                            alignment: Alignment.topLeft,
                            child: new Text(
                              "\$" + cartData[index]['yourprice'],
                              style: TextStyle(
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          )
                        ],
                      ),
                      trailing: FittedBox(
                        fit: BoxFit.fill,
                        child: Column(
                          children: <Widget>[
                            new FlatButton(
                              child: Icon(
                                Icons.arrow_drop_up,
                                size: 100.0,
                              ),
                              onPressed: () => {
                                _updateCart(index, "add"),
                              },
                            ),
                            new Text(
                              cartData[index]['cquantity'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                                fontSize: 60,
                              ),
                            ),
                            new FlatButton(
                              child: Icon(Icons.arrow_drop_down, size: 100.0),
                              onPressed: () => {_updateCart(index, "remove")},
                            ),
                          ],
                        ),
                      )),
                );
              }),
        ),
      );
    }
  }

  void _loadCart() {
    _totalprice = 0.0;
    amountpayable = 0.0;
    deliverycharge = 0.0;
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false);
    pr.style(message: "Updating cart...");
    pr.show();
    String urlLoadJobs = server + "/php/load_cart.php";
    http.post(urlLoadJobs, body: {
      "email": widget.user.email,
    }).then((res) {
      print(res.body);
      pr.dismiss();
      if (res.body == "Cart Empty") {
        //Navigator.of(context).pop(false);
        widget.user.quantity = "0";
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => MainScreen(
                      user: widget.user,
                    )));
      }

      setState(() {
        var extractdata = json.decode(res.body);
        cartData = extractdata["cart"];
        for (int i = 0; i < cartData.length; i++) {
          _totalprice = double.parse(cartData[i]['yourprice']) + _totalprice;
        }

        amountpayable = _totalprice;

        print(_totalprice);
      });
    }).catchError((err) {
      print(err);
      pr.dismiss();
    });
    pr.dismiss();
  }

  _updateCart(int index, String op) {
    int curquantity = int.parse(cartData[index]['quantity']);
    int quantity = int.parse(cartData[index]['cquantity']);
    if (op == "add") {
      quantity++;
      if (quantity > (curquantity - 2)) {
        Toast.show("Quantity not available", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return;
      }
    }
    if (op == "remove") {
      quantity--;
      if (quantity == 0) {
        _deleteCart(index);
        return;
      }
    }
    String urlLoadJobs =
        "https://seriouslaa.com/goldenbread/php/update_cart.php";
    http.post(urlLoadJobs, body: {
      "email": widget.user.email,
      "prodid": cartData[index]['id'],
      "quantity": quantity.toString()
    }).then((res) {
      print(res.body);
      if (res.body == "success") {
        Toast.show("Cart Updated", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _loadCart();
      } else {
        Toast.show("Failed", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }).catchError((err) {
      print(err);
    });
  }

  _deleteCart(int index) {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Text(
          'Delete item?',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                http.post(
                    "https://seriouslaa.com/goldenbread/php/delete_cart.php",
                    body: {
                      "email": widget.user.email,
                      "prodid": cartData[index]['id'],
                    }).then((res) {
                  print(res.body);
                  if (res.body == "success") {
                    _loadCart();
                  } else {
                    Toast.show("Failed", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  }
                }).catchError((err) {
                  print(err);
                });
              },
              child: Text(
                "Yes",
                style: TextStyle(
                  color: Colors.red[400],
                ),
              )),
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red[400],
                ),
              )),
        ],
      ),
    );
  }

  void _onSelfPickUp(bool newValue) => setState(() {
        _selfPickup = newValue;
        if (_selfPickup) {
          _homeDelivery = false;
          _updatePayment();
        } else {
          //_homeDelivery = true;
          _updatePayment();
        }
      });

  void _onStoreCredit(bool newValue) => setState(() {
        _storeCredit = newValue;
        if (_storeCredit) {
          _updatePayment();
        } else {
          _updatePayment();
        }
      });

  void _onHomeDelivery(bool newValue) {
    //_getCurrentLocation();
    _getLocation();
    setState(() {
      _homeDelivery = newValue;
      if (_homeDelivery) {
        _updatePayment();
        _selfPickup = false;
      } else {
        _updatePayment();
      }
    });
  }

  _getLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //debugPrint('location: ${_currentPosition.latitude}');
    final coordinates =
        new Coordinates(_currentPosition.latitude, _currentPosition.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    setState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });

    print("${first.featureName} : ${first.addressLine}");
  }

  _getLocationfromlatlng(double lat, double lng, newSetState) async {
    final Geolocator geolocator = Geolocator()
      ..placemarkFromCoordinates(lat, lng);
    _currentPosition = await geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    //debugPrint('location: ${_currentPosition.latitude}');
    final coordinates = new Coordinates(lat, lng);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    newSetState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });
    setState(() {
      curaddress = first.addressLine;
      if (curaddress != null) {
        latitude = _currentPosition.latitude;
        longitude = _currentPosition.longitude;
        return;
      }
    });

    print("${first.featureName} : ${first.addressLine}");
  }

  _loadMapDialog() {
    try {
      if (_currentPosition.latitude == null) {
        Toast.show("Location not available. Please wait...", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        _getLocation(); //_getCurrentLocation();
        return;
      }
      _controller = Completer();
      _userpos = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 14.4746,
      );

      markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'Current Location',
            snippet: 'Delivery Location',
          )));

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, newSetState) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20.0))),
                title: Text(
                  "Select New Delivery Location",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                titlePadding: EdgeInsets.all(5),
                //content: Text(curaddress),
                actions: <Widget>[
                  Text(
                    curaddress,
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    height: screenHeight / 2 ?? 600,
                    width: screenWidth ?? 360,
                    child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: _userpos,
                        markers: markers.toSet(),
                        onMapCreated: (controller) {
                          _controller.complete(controller);
                        },
                        onTap: (newLatLng) {
                          _loadLoc(newLatLng, newSetState);
                        }),
                  ),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    //minWidth: 200,
                    height: 30,
                    child: Text('Close'),
                    color: Colors.red,
                    textColor: Colors.white,
                    elevation: 10,
                    onPressed: () =>
                        {markers.clear(), Navigator.of(context).pop(false)},
                  ),
                ],
              );
            },
          );
        },
      );
    } catch (e) {
      print(e);
      return;
    }
  }

  void _loadLoc(LatLng loc, newSetState) async {
    newSetState(() {
      print("insetstate");
      markers.clear();
      latitude = loc.latitude;
      longitude = loc.longitude;
      _getLocationfromlatlng(latitude, longitude, newSetState);
      _home = CameraPosition(
        target: loc,
        zoom: 14,
      );
      markers.add(Marker(
          markerId: markerId1,
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(
            title: 'New Location',
            snippet: 'New Delivery Location',
          )));
    });
    _userpos = CameraPosition(
      target: LatLng(latitude, longitude),
      zoom: 14.4746,
    );
    _newhomeLocation();
  }

  Future<void> _newhomeLocation() async {
    gmcontroller = await _controller.future;
    gmcontroller.animateCamera(CameraUpdate.newCameraPosition(_home));
    //Navigator.of(context).pop(false);
    //_loadMapDialog();
  }

  void _updatePayment() {
    _totalprice = 0.0;
    amountpayable = 0.0;
    setState(() {
      for (int i = 0; i < cartData.length; i++) {
        _totalprice = double.parse(cartData[i]['yourprice']) + _totalprice;
      }

      print(_selfPickup);
      if (_selfPickup) {
        deliverycharge = 0.0;
      }
      if (_homeDelivery) {
        deliverycharge = _totalprice * 0.03;
      }
      if (_storeCredit) {
        amountpayable =
            deliverycharge + _totalprice - double.parse(widget.user.credit);
      } else {
        amountpayable = deliverycharge + _totalprice;
      }
      print("Dev Charge:" + deliverycharge.toStringAsFixed(3));
      print(_totalprice);
    });
  }

  void makePaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Text(
          'Proceed with payment?',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        content: new Text(
          'Are you sure?',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                makePayment();
              },
              child: Text(
                "Ok",
                style: TextStyle(
                  color: Colors.red[400],
                ),
              )),
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red[400],
                ),
              )),
        ],
      ),
    );
  }

  Future<void> makePayment() async {
    if (amountpayable < 0) {
      double newamount = amountpayable * -1;
      await _payusingstorecredit(newamount);
      _loadCart();
      return;
    }
    if (_selfPickup) {
      print("PICKUP");
      Toast.show("Self Pickup", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else if (_homeDelivery) {
      print("HOME DELIVERY");
      Toast.show("Home Delivery", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      Toast.show("Please select delivery option", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
    var now = new DateTime.now();
    var formatter = new DateFormat('ddMMyyyy-');
    String orderid = widget.user.email.substring(1, 4) +
        "-" +
        formatter.format(now) +
        randomAlphaNumeric(6);
    print(orderid);
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => PaymentScreen(
                  user: widget.user,
                  val: amountpayable.toStringAsFixed(2),
                  orderid: orderid,
                )));
    _loadCart();
  }

  void deleteAll() {
    showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20.0))),
        title: new Text(
          'Delete all items?',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                http.post(server + "/php/delete_cart.php", body: {
                  "email": widget.user.email,
                }).then((res) {
                  print(res.body);

                  if (res.body == "success") {
                    _loadCart();
                  } else {
                    Toast.show("Failed", context,
                        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                  }
                }).catchError((err) {
                  print(err);
                });
              },
              child: Text(
                "Yes",
                style: TextStyle(
                  color: Colors.red[400],
                ),
              )),
          MaterialButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red[400],
                ),
              )),
        ],
      ),
    );
  }

  String generateOrderid() {
    var now = new DateTime.now();
    var formatter = new DateFormat('ddMMyyyy-');
    String orderid = widget.user.email.substring(1, 4) +
        "-" +
        formatter.format(now) +
        randomAlphaNumeric(6);
    return orderid;
  }

  Future<void> _payusingstorecredit(double newamount) async {
    //insert carthistory
    //remove cart content
    //update product quantity
    //update credit in user
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: true);
    pr.style(message: "Updating cart...");
    pr.show();
    String urlPayment = server + "/php/paymentsc.php";
    await http.post(urlPayment, body: {
      "userid": widget.user.email,
      "amount": _totalprice.toStringAsFixed(2),
      "orderid": generateOrderid(),
      "newcr": newamount.toStringAsFixed(2)
    }).then((res) {
      print(res.body);
      pr.dismiss();
    }).catchError((err) {
      print(err);
    });
  }
}
