
import 'package:flutter/material.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final String name;
  RestaurantDetailsScreen(this.name);

  @override
  State<RestaurantDetailsScreen> createState() => _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Text("data");
  }
}
